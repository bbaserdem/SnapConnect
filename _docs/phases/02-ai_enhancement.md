# Phase 2: RAG-based Auto-Tagging

**Goal**: To implement an end-to-end Retrieval-Augmented Generation (RAG) pipeline for automatically suggesting relevant tags for user-generated images. This involves strengthening the in-app tagging system and building a Python-based cloud function to power the AI.

---

## Key Tasks & Features

### 1. Robust Tagging System
- **Description**: Enhance the application's data models and UI to support a more dynamic and robust tagging system. Tags will be sourced from an external file and displayed asynchronously on Snaps and Stories.
- **Tech Stack**: `Flutter`, `Firestore`, `assets/tags.txt`.
- **Steps**:
    1.  Create a utility service in Flutter to read and parse `assets/tags.txt` into a globally accessible list.
    2.  On the user profile setup screen, display a curated subset of these tags for users to select as their core interests. Store the selections in the user's Firestore document.
    3.  Modify the `Snap` and `Story` data models in Firestore to include an optional `tags` field (e.g., `List<String>`).
    4.  Update the UI to display these tags. For image-based Stories, show them at the bottom of the screen. For Snaps, display them under the message content.
    5.  Ensure the UI is robust to asynchronicity. It should not break if the `tags` field is initially empty but should update gracefully when the tags are populated by the backend.

### 2. RAG Implementation for Auto-Tagging
- **Description**: Develop and deploy a RAG pipeline on Firebase Cloud Functions using Python. This function will analyze new images, retrieve relevant tags from a specialized vector index, and assign them to the content.
- **Tech Stack**: `Firebase Functions (Python)`, `OpenAI (GPT-4 Vision, GPT-4, text-embedding-ada-002)`, `Firestore`, `FAISS`.
- **Steps**:
    1.  Initialize a Python-based Firebase Functions codebase. Note that your `flake.nix` already contains a Python environment with the necessary packages.
    2.  Create a one-off Python script to be run locally. This script will:
        a. Read the tags from `assets/tags.txt`.
        b. Use OpenAI's `text-embedding-ada-002` model to create vector embeddings for each tag.
        c. Build a FAISS vector index from these embeddings and save the index file. This file will be deployed alongside the cloud function.
    3.  Create a Cloud Function triggered by new image uploads to Firebase Storage.
    4.  Within the function:
        a. Use `GPT-4 Vision` to generate a rich description of the uploaded image.
        b. Generate an embedding for this description using `text-embedding-ada-002`.
        c. Use the pre-built FAISS index to perform a similarity search and retrieve the most relevant tags (the "retrieval" step).
        d. Use GPT-4 to review the retrieved tags against the image description and filter out any irrelevant ones (the "validation" step).
        e. Update the corresponding `Snap` or `Story` document in Firestore with the validated tags. 