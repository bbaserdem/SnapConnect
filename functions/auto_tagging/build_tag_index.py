#!/usr/bin/env python3
"""build_tag_index.py

One-off script to create a FAISS vector index from the project's `assets/tags.yaml` file.

Usage (run from repository root):
    python functions/auto_tagging/build_tag_index.py

It will output two files in the same folder:
    - tags.index : FAISS binary index of shape (N, embedding_dim)
    - tags.json  : sidecar file with ordered list of tag strings corresponding to vectors

Those files should be deployed alongside the Cloud Function so it can do similarity search
without recomputing embeddings.
"""

from __future__ import annotations

import json
import os
from pathlib import Path
import sys

import numpy as np
import openai
import faiss  # type: ignore
import yaml

# Constants ---------------------------------------------------------------------
ROOT = Path(__file__).resolve().parents[2]  # repository root
TAGS_YAML_PATH = ROOT / "assets" / "tags.yaml"
OUTPUT_DIR = Path(__file__).resolve().parent
INDEX_PATH = OUTPUT_DIR / "tags.index"
TAGS_JSON_PATH = OUTPUT_DIR / "tags.json"
EMBED_MODEL = "text-embedding-ada-002"


# Helpers -----------------------------------------------------------------------

def load_tags() -> list[str]:
    """Return list of unique tag strings in original order from tags.yaml."""
    with open(TAGS_YAML_PATH, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f)
    seen: set[str] = set()
    tags: list[str] = []
    for entry in data:
        tag = str(entry["tag"]).strip()
        if tag and tag not in seen:
            seen.add(tag)
            tags.append(tag)
    return tags


def embed_texts(texts: list[str]) -> np.ndarray:
    """Call OpenAI embedding endpoint and return ndarray (N, dim)."""
    openai.api_key = os.getenv("OPENAI_API_KEY")
    if not openai.api_key:
        raise SystemExit("OPENAI_API_KEY environment variable not set")

    # OpenAI allows batching up to 2048 tokens across inputs; small list is fine.
    response = openai.embeddings.create(model=EMBED_MODEL, input=texts)
    # Each response item contains .embedding
    vectors = np.array([d.embedding for d in response.data], dtype="float32")
    return vectors


def main() -> None:
    tags = load_tags()
    print(f"Loaded {len(tags)} unique tags from YAML")

    vectors = embed_texts(tags)
    dim = vectors.shape[1]
    print(f"Embedding dimension: {dim}")

    index = faiss.IndexFlatIP(dim)  # inner-product for cosine similarity (normalized)
    # Normalize vectors to unit length
    faiss.normalize_L2(vectors)
    index.add(vectors)

    faiss.write_index(index, str(INDEX_PATH))
    TAGS_JSON_PATH.write_text(json.dumps(tags, ensure_ascii=False, indent=2))

    print(f"Wrote index to {INDEX_PATH.relative_to(ROOT)}")
    print(f"Wrote tag list to {TAGS_JSON_PATH.relative_to(ROOT)}")


if __name__ == "__main__":
    main() 