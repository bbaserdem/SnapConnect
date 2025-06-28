# Product Requirements Document (PRD)

This document provides a comprehensive overview of the project, including its core purpose, user flows, and detailed feature requirements.

---

## 1. Project Overview

This project is a speed build challenge to build a fully functional Snapchat clone that will have RAG features.
This clone will focus on the needs of the following user case; **body mod enthusiasts**.
After building the Snapchat clone, our next task is to enhance it with advanced AI-driven RAG features.
The goal is to leverage modern AI development tools and methodologies throughout the process.

### Phase 0: Mobile App Development

Get our tech stack working so that we have an app on the phone that can display `hello world` using our selected tech stack.

### Phase 1: Core Clone

Develop the core features of the Snapchat clone, including:

- **Real-time photo/video sharing with disappearing messages**
- **Simple AR filters and camera effects**
- **User authentication and friend management**
- **Stories and group messaging functionality**
- **Core social features matching Snapchat's core experience**


### Phase 2: AI Enhancement

Elevate the clone by integrating advanced RAG features using AI tailored to a specific niche:

- **Context-aware friend and content recommendations**
- **AI-generated content ideas and prompts**
- **Intelligent caption and story suggestions using RAG**
- **Personalized content generation based on user interests and history**


### Ultimate Goal

Deliver a next-generation snapchat clone that demonstrates how AI-first principles
can transform social media landscape.

---

## 2. User Flow

This section outlines the user journey for the Snapchat clone, focusing on the experience of a body mod enthusiast.
The flow covers onboarding, content creation, sharing, and interaction with AI-driven features.

### 2.1. User Stories

We will be using bodymod enthusiast as our primary users.

#### Core functionality stories

- As a bodymod enthusiast, I want to be able to send ephemeral messages so that I can keep private communications private.
- As a bodymod enthusiast, I want to share my mods with other people, either privately through DMs or publically from stories.
- As a bodymod enthusiast, I want to see stories by people with body mods to discuss the benefits and challenges of body mods.

#### AI Enhancement RAG stories

- As a bodymod enthusiast, I want AI to automatically tag which bodymod I'm featuring in my messages or stories.
- As a bodymod enthusiast, I want to be able to look up stories with the tags I want
- As a bodymod enthusiast, I want to connect with new people who have the bodymod I'm interested in.
- As a bodymod enthusiast, I want to be recommended bodymods suggested by my activity and engagement patterns.

### 2.2. Onboarding

The primary goal of onboarding is to get the user set up and ready to create and share content.

1.  **Launch App**: User opens the app for the first time.
2.  **Sign Up / Log In**: User is presented with options to sign up or log in. The signup process will ask for basic information like name, username, password, and birthday.
3.  **Profile Setup**:
    *   The user selects tags relevant to their interests (e.g., tattoos, piercings, heavy mods, implants, gender affirming, plastic surgery).
    *   The user can optionally add a profile picture and a short bio.
4.  **Permissions**: The app requests necessary permissions: Camera, Microphone, Notifications, and Contacts (for friend finding).
5.  **Landing Screen**: After onboarding, the user lands on the main Camera screen, ready to create content.

### 2.3. Core User Journey: The Content Loop

This section describes the primary loop of creating, sharing, and consuming content.

#### 2.3.1. Main Application Navigation

The main application interface is organized into a series of tabs for easy navigation between key features:

*   **Snap Tab**: The default view, which opens directly into the camera for immediate content creation.
*   **Friends Tab**: Allows users to view their current friends list and search for new friends to add.
*   **Messages Tab**: A central hub for viewing and sending direct messages. Group chats are also managed within this tab.
*   **Stories Tab**: A dedicated section for viewing stories shared by other users.

#### 2.3.2. Creating a Snap (Photo/Video)

1.  **Open Camera**: The app opens directly to the camera view.
3.  **Capture Content**: User can tap to take a photo or press and hold to record a video.
4.  **Apply Effects**: User can swipe to browse and apply simple AR filters and camera effects.
5.  **Edit and Enhance**:
    *   After capturing, the user enters an edit screen where they can add text.
    *   **AI-Powered Suggestions**: A button is available for the user to opt-in to intelligent captions and tags. This process runs in the background to avoid blocking the UI, and the generated content is appended to any manual captions. For now, personalized content generation is limited to these automatic captions and tags.
6.  **Set Timer**: User can set how long the snap will be visible to friends.

#### 2.3.3. Sharing Content

Once a snap is created, the user chooses how to share it.

1.  **Select Audience**: From the "Send To" screen, the user can select:
    *   **My Story**: Posts the snap to their public or friends-only story for 24 hours.
    *   **Specific Friends**: Sends the snap as a direct, disappearing message.
    *   **Groups**: Shares the snap in a group chat.
2.  **Send**: User hits the send button to distribute the content.

#### 2.3.4. Consuming Content

Users consume content from their friends and the wider community.

1.  **Viewing Direct Snaps**:
    *   Users get notifications for new snaps.
    *   They can view them from their chat list. The message disappears after viewing.
2.  **Watching Stories**:
    *   Users can view friend stories from a dedicated Stories screen.
    *   Stories are available for 24 hours.
3.  **Interacting with Group Chats**:
    *   Users can view snaps and text messages in group chats.

### 2.4. Social & Community Features

This section covers how users build and manage their social network.

#### 2.4.1. Friend Management

1.  **Adding Friends**: Users can add friends by searching for a username, adding from phone contacts, or using Snapcodes (if this feature is cloned).
2.  **AI Friend Recommendations**: Context-aware friend and content recommendations appear in the "Add Friends" menu.
    *   **For Regular Users**: When the search bar is empty, the menu is populated with suggested friends.

#### 2.4.2. Content Discovery

*   **Assumption**: Beyond friends' stories, there will be a way to discover content from other users, likely through the AI recommendations mentioned above.
*   **Clarification**: There will be, but it's beyond the scope of the app for now. We will add it into the future features list.

### 2.5. Future Features

This section lists features that are planned for future releases but are out of scope for the initial build.

*   **Content Discovery Page**: A dedicated section for discovering content from creators the user doesn't follow.
*   **AI-Generated Story Outlines**: Advanced AI feature to generate multi-snap story outlines based on user prompts.
*   **Drawings and Stickers**: Additional creative tools for editing snaps.

---

## 3. Feature: Group Messaging

### 3.1. Introduction / Overview
Group Messaging enables casual multi-user chats for sharing Snaps and text with up to ten people.  It extends the existing 1-to-1 messaging system so users can create a named room at snap-time (or from the Messages tab) and converse together.  All participants have equal privileges—there are no admins or moderators.  Membership is fixed at creation, but any participant may leave at any time.

### 3.2. Goals
1. Allow a user to create a new group chat with 2–10 participants and a group name.
2. Allow participants to send text, images, videos, and Snaps to the group.
3. Apply the updated disappearing-Snap logic consistently across both direct and group chats.
4. Provide unread counts and push/foreground notifications for new group messages.
5. Maintain UX and performance parity with existing direct-message flows.

### 3.3. User Stories
* **US-G1** – As a user, I can select multiple friends (≤ 9) and assign a group name so that we can chat together.
* **US-G2** – As a participant, I can send text or media and view others' messages in real time.
* **US-G3** – As a participant, I can leave the group at any time, removing the conversation from my list.
* **US-G4** – As the original sender of a Snap, I can still view my own Snap after others have viewed it.
* **US-G5** – As a participant, I can open an unread Snap exactly once; afterwards it is greyed-out and unavailable to me.
* **US-G6** – As a user, I receive a notification badge / push alert when new messages arrive in my groups.

### 3.4. Functional Requirements
1. **Group Creation**
   1.1 The system shall allow selection of 1–9 friends and entry of a non-empty group name (max 30 chars).
   1.2 Upon creation, the system shall write a `conversations/{conversationId}` document with `isGroup = true` and an array `participantIds` (≤ 10).
2. **Sending Messages**
   2.1 The system shall reuse `messages` collection schema; `isGroupMessage = true`.
   2.2 The system shall broadcast messages via Firestore listeners identical to direct chat.
3. **Snap Behaviour**
   3.0 **Applicability** – The rules below replace the previous per-chat logic and apply to *all* conversations (direct and group).
   3.1 If a Snap is marked *persistent*, it remains viewable by all users indefinitely (subject to storage TTL).
   3.2 If a Snap is marked *disappearing*:
        • Each participant may view it once; after viewing, the message is visually disabled for that user.
        • The sender may re-view their own Snap at will.
        • The Snap is **not** deleted from Firestore; instead a per-user flag `viewedBy` determines availability.
        • Media file is automatically deleted from Firebase Storage after 24 h via TTL rule (reuse story logic).
4. **Leaving Group**
   4.1 Any participant may leave; the client shall remove the conversation from their local list and append their UID to `deletedFor` array in Firestore.
   4.2 If all participants leave, no special clean-up is required—the conversation becomes orphaned and will age out when media TTLs expire.
5. **Unread & Notifications**
   5.1 The system shall increment `unreadCounts[uid]` for each participant on new messages.
   5.2 The system shall trigger FCM push notifications using Cloud Functions when `isGroup = true`.
6. **Constraints**
   6.1 Max 10 participants enforced both on client and in Cloud Function validation.
   6.2 No role management; all users share identical permissions.

### 3.5. Non-Goals (Out of Scope)
* Mid-life member invites or kicks.
* Admin/moderator hierarchy.
* Message reactions, typing indicators, read receipts beyond the existing `viewedBy` array.
* Muting, @mentions, or advanced notification controls.
* Group avatars or custom themes.

### 3.6. Design Considerations (Optional)
* **UI** – Reuse `NewMessageDialog` flow: add a "Create Group" toggle that opens multi-select friend picker and name field.
* **List Tile** – Use the first two letter initials of the group name as avatar; fallback to default group icon.
* **Message Bubble** – Prefix messages with sender's name in group chats.

### 3.7. Technical Considerations (Optional)
* **Schema Migration** – Minimal: add `isGroup`, `groupName` (string), and `deletedFor` (array) to `conversations` docs.
* **Security Rules** – Update Firestore rules: users may read/write only if they are in `participantIds`.
* **Cloud Function** – Enforce ≤ 10 participant rule, generate notifications, and schedule Storage TTL if not handled by bucket policy.
* **Offline Cache** – Extend Isar models to include `isGroup` and `groupName` as needed.

### 3.8. Success Metrics
* ≥ 90 % of beta testers can successfully create a group and exchange at least one Snap.
* Average message delivery latency < 1 s (same as direct chat).
* Zero regression in existing direct-message flows (measured by integration tests).

### 3.9. Open Questions
1. Should the group name be editable later (by all participants) or locked forever? *Locked forever*
2. Do we show a "left the group" system message when someone exits? *We do show this message*
3. Are sender-side controls (delete for everyone / delete for me) required? *Not required, baked into snap persistence/ephemeral behavior* 