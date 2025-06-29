"""auto_tag_function.py

Firebase Cloud Function (Python) for automatic tag suggestion.
Triggered on *finalize* (upload) events for **both** `messages/` and `stories/` folders
inside the default Storage bucket. The function:

1. Generates a signed URL valid for a few minutes.
2. Calls GPT-4o-Vision with that URL ➔ image description.
3. Embeds description (OpenAI `text-embedding-ada-002`).
4. FAISS similarity search over `tags.index` (built offline) to fetch top-k tags.
5. GPT-4o review call to filter to ≤3 tags.
6. Writes tags back to Firestore:
   • stories.{userId}.media[?id==<media_id>].tags
   • messages.{messageId}.tags

Note: for simplicity the mapping from Storage path ➔ Firestore IDs assumes
  – Stories:   stories/<userId>/<media_id>.<ext>
  – Messages:  messages/<file_name>
Adjust `parse_paths` as needed to align with your actual naming scheme.
"""

from __future__ import annotations

import base64
import json
import os
import urllib.parse
from pathlib import Path
from typing import List, Any

# Delay heavy native imports so Firebase CLI analysis (which just imports the
# module to discover function definitions) doesn't require compiled deps.
# They are imported lazily inside handlers when the Cloud Function actually
# executes in the managed runtime.

# We purposefully avoid importing faiss/numpy at module import time because the
# local Firebase CLI environment might lack system libs (e.g., libstdc++.so.6)
# causing discovery to fail. They are required only inside `load_index` and the
# embedding step respectively.

# Framework import is lightweight; keep.
import functions_framework  # Cloud Functions v2 python framework

# Avoid importing heavy google.cloud libraries at module load time because
# their native grpc dependencies may be missing in the Firebase CLI analysis
# container. They are imported lazily inside runtime paths.

ROOT = Path(__file__).parent
INDEX_PATH = ROOT / "tags.index"
TAGS_JSON_PATH = ROOT / "tags.json"
EMBED_MODEL = "text-embedding-ada-002"
VISION_MODEL = "gpt-4o-mini"  # update if needed
CHAT_MODEL = "gpt-4o-mini"
TOP_K = 8  # retrieve top-k before validation
FINAL_K = 3  # tags to write back
SIGNED_URL_TTL = 15 * 60  # seconds

# --------------------------------------------------------------------------------------
# Lazy-load FAISS index & tag list into global memory (warm across invocations)
_index = None  # type: ignore
_tag_list: List[str] | None = None


def load_index():
    global _index, _tag_list
    if _index is not None:
        return _index, _tag_list
    if not INDEX_PATH.exists() or not TAGS_JSON_PATH.exists():
        raise RuntimeError("FAISS index or tag list missing in function directory")
    # Import faiss and numpy here to avoid import errors during Firebase CLI analysis
    import faiss  # type: ignore
    import numpy as np
    _index = faiss.read_index(str(INDEX_PATH))
    _tag_list = json.loads(TAGS_JSON_PATH.read_text())
    return _index, _tag_list


# --------------------------------------------------------------------------------------
# Event handler


@functions_framework.cloud_event
def auto_tag_image(cloud_event):
    """Entry point for the Cloud Function."""
    data = cloud_event.data
    bucket_name = data["bucket"]
    file_path = data["name"]  # e.g. messages/abc/xyz.jpg

    # Only handle images under messages/ or stories/
    if not (file_path.startswith("messages/") or file_path.startswith("stories/")):
        return  # ignore other uploads

    print("Received upload event for", file_path)

    openai.api_key = os.environ["OPENAI_API_KEY"]

    from google.cloud import storage  # local import to avoid grpc load at discovery
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(file_path)

    # Create signed URL so OpenAI Vision can fetch the image
    signed_url = blob.generate_signed_url(expiration=SIGNED_URL_TTL, method="GET")

    # 1. Vision description ------------------------------------------------------
    vision_prompt = [
        {
            "type": "text",
            "text": "Describe the visual content for tagging a body-modification social app.",
        },
        {"type": "image_url", "image_url": {"url": signed_url}},
    ]
    vision_resp = openai.chat.completions.create(
        model=VISION_MODEL,
        messages=[{"role": "user", "content": vision_prompt}],
        max_tokens=256,
    )
    description = vision_resp.choices[0].message.content.strip()
    print("Vision description:", description)

    # 2. Embed description -------------------------------------------------------
    embed_resp = openai.embeddings.create(input=description, model=EMBED_MODEL)
    import numpy as np  # local import to avoid global dependency during analysis
    import faiss  # ensure faiss available as well for normalize
    vector = np.array(embed_resp.data[0].embedding, dtype="float32").reshape(
        1, -1
    )
    faiss.normalize_L2(vector)

    # 3. Similarity search -------------------------------------------------------
    index, tag_list = load_index()
    distances, indices = index.search(vector, TOP_K)
    candidate_tags = [tag_list[i] for i in indices[0] if i != -1]
    print("Candidate tags:", candidate_tags)

    # 4. GPT-4 filtering ---------------------------------------------------------
    system_prompt = (
        f"You are selecting at most {FINAL_K} relevant tags from a list for an image described as:\n'{description}'\nTags: {', '.join(candidate_tags)}"
    )
    filter_resp = openai.chat.completions.create(
        model=CHAT_MODEL,
        messages=[{"role": "system", "content": system_prompt}],
        max_tokens=64,
    )
    validated = [
        t.strip().lower()
        for t in filter_resp.choices[0].message.content.split(",")
    ]
    validated = [t for t in validated if t]
    validated = validated[:FINAL_K]

    print("Validated tags:", validated)

    # 5. Persist to Firestore ----------------------------------------------------
    from google.cloud import firestore  # local import
    db = firestore.Client()
    if file_path.startswith("stories/"):
        handle_story_update(db, file_path, validated)
    else:
        handle_message_update(db, file_path, bucket_name, validated)


# --------------------------------------------------------------------------------------
# Firestore write helpers


def handle_story_update(db, file_path: str, tags: List[str]):
    # Extract userId & media_id from path stories/<userId>/<media_id>.*
    parts = file_path.split("/")
    if len(parts) < 3:
        print("Unrecognised story path", file_path)
        return
    user_id, media_filename = parts[1], parts[2]
    media_id = os.path.splitext(media_filename)[0]

    doc_ref = db.collection("stories").document(user_id)
    doc = doc_ref.get()
    if not doc.exists:
        print("Story document not found for", user_id)
        return
    data = doc.to_dict()
    media_list = data.get("media", [])
    modified = False
    for item in media_list:
        if item.get("id") == media_id:
            item["tags"] = tags
            modified = True
            break
    if modified:
        doc_ref.update({"media": media_list})
        print("Updated story tags for", media_id)
    else:
        print("Media ID", media_id, "not found in story doc")


def handle_message_update(db, file_path: str, bucket_name: str, tags: List[str]):
    encoded_path = urllib.parse.quote(file_path, safe="")
    prefix_url = (
        f"https://firebasestorage.googleapis.com/v0/b/{bucket_name}/o/"
        f"{encoded_path}?alt=media"
    )

    # Perform a range query to find documents whose mediaUrl starts with the prefix.
    docs = list(
        db.collection("messages")
        .order_by("mediaUrl")
        .start_at({"mediaUrl": prefix_url})
        .end_at({"mediaUrl": prefix_url + "\uf8ff"})
        .limit(1)
        .stream()
    )
    if not docs:
        print("No message document found matching mediaUrl prefix", prefix_url)
        return
    doc_ref = docs[0].reference
    doc_ref.update({"tags": tags})
    print("Updated message tags for", doc_ref.id)


# --- Firebase Functions discovery wrapper (after import attempt) ---
# if fb_funcs is not None:
#     auto_tag_image_fn = storage_fn.on_object_finalized()(auto_tag_image)

# Placeholder to ensure symbol exists even if import fails
fb_funcs = None  # type: ignore

try:
    import firebase_functions as fb_funcs  # noqa: F401
    from firebase_functions import storage_fn
except ImportError:
    pass

# After successful import of firebase_functions
DEFAULT_BUCKET = "snapconnect-bodymod.firebasestorage.app"

# Register the function with Firebase if the SDK is available
if fb_funcs is not None:
    auto_tag_image_fn = storage_fn.on_object_finalized(bucket=DEFAULT_BUCKET)(auto_tag_image)

import openai

