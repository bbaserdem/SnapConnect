# Group Messaging – Product Requirements Document (PRD)

## 1. Introduction / Overview
Group Messaging enables casual multi-user chats for sharing Snaps and text with up to ten people.  It extends the existing 1-to-1 messaging system so users can create a named room at snap-time (or from the Messages tab) and converse together.  All participants have equal privileges—there are no admins or moderators.  Membership is fixed at creation, but any participant may leave at any time.

## 2. Goals
1. Allow a user to create a new group chat with 2–10 participants and a group name.
2. Allow participants to send text, images, videos, and Snaps to the group.
3. Apply the updated disappearing-Snap logic consistently across both direct and group chats.
4. Provide unread counts and push/foreground notifications for new group messages.
5. Maintain UX and performance parity with existing direct-message flows.

## 3. User Stories
* **US-G1** – As a user, I can select multiple friends (≤ 9) and assign a group name so that we can chat together.
* **US-G2** – As a participant, I can send text or media and view others' messages in real time.
* **US-G3** – As a participant, I can leave the group at any time, removing the conversation from my list.
* **US-G4** – As the original sender of a Snap, I can still view my own Snap after others have viewed it.
* **US-G5** – As a participant, I can open an unread Snap exactly once; afterwards it is greyed-out and unavailable to me.
* **US-G6** – As a user, I receive a notification badge / push alert when new messages arrive in my groups.

## 4. Functional Requirements
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

## 5. Non-Goals (Out of Scope)
* Mid-life member invites or kicks.
* Admin/moderator hierarchy.
* Message reactions, typing indicators, read receipts beyond the existing `viewedBy` array.
* Muting, @mentions, or advanced notification controls.
* Group avatars or custom themes.

## 6. Design Considerations (Optional)
* **UI** – Reuse `NewMessageDialog` flow: add a "Create Group" toggle that opens multi-select friend picker and name field.
* **List Tile** – Use the first two letter initials of the group name as avatar; fallback to default group icon.
* **Message Bubble** – Prefix messages with sender's name in group chats.

## 7. Technical Considerations (Optional)
* **Schema Migration** – Minimal: add `isGroup`, `groupName` (string), and `deletedFor` (array) to `conversations` docs.
* **Security Rules** – Update Firestore rules: users may read/write only if they are in `participantIds`.
* **Cloud Function** – Enforce ≤ 10 participant rule, generate notifications, and schedule Storage TTL if not handled by bucket policy.
* **Offline Cache** – Extend Isar models to include `isGroup` and `groupName` as needed.

## 8. Success Metrics
* ≥ 90 % of beta testers can successfully create a group and exchange at least one Snap.
* Average message delivery latency < 1 s (same as direct chat).
* Zero regression in existing direct-message flows (measured by integration tests).

## 9. Open Questions
1. Should the group name be editable later (by all participants) or locked forever? *Locked forever*
2. Do we show a "left the group" system message when someone exits? *We do show this message*
3. Are sender-side controls (delete for everyone / delete for me) required? *Not required, baked into snap persistence/ephemeral behavior*

---

*Draft compiled 2025-06-27 based on user clarifications.* 

## Implementation

> We will implement the feature incrementally.  Each step below is a sub-task we will check off as completed.
>
> **Protocol:** After finishing a sub-task I will (1) update this list by changing `[ ]` to `[x]`, (2) briefly summarise the work done, and (3) wait for your "yes/y" before starting the next sub-task.

### 0. Preparatory
- [x] 0.1 Create `tasks/impl-phase1.7.md` (living task log as per `process-task-list` rule) and move this checklist there for easier diff-tracking.

### 1. Data Layer
- [x] 1.1 Extend Firestore security rules & indexes for group conversations.
- [x] 1.2 Ensure `ConversationModel` already supports `isGroup`, `groupName`; add `deletedFor` array.
- [x] 1.3 Add repository method `createGroupConversation()` enforcing ≤ 10 participants and writing schema.
- [x] 1.4 Add repository method `leaveConversation()` that appends UID to `deletedFor`.

### 2. Snap Protocol Refactor
- [x] 2.1 Update `MessagingRepository.markMessageAsViewed()` and `_scheduleMessageDeletion()` so Snaps are **not** deleted on view—only `viewedBy` updated.
- [x] 2.2 Remove eager deletion of Snap docs from `_cleanupExpiredMessages`; instead, set `isExpired=true` and strip media URLs only after `expiresAt`.

### 3. UI / Presentation Layer
- [x] 3.1 Extend `NewMessageDialog` with a "Group Chat" toggle that opens multi-select friend picker + group-name field.
- [x] 3.2 Show sender's display name above each bubble in group chats (`chat_screen.dart`).
- [x] 3.3 Update `ConversationTile` avatar to show two-letter group initials when `isGroup`.
- [x] 3.4 Add long-press "Leave Group" action in chat screen (calls `leaveConversation`).

### 4. Notifications & Unread Counts
- [x] 4.1 Update unread logic in repository to increment counts for all participants (except sender).
- [x] 4.2 Add simple Cloud Function placeholder (comment-only) for push notifications (implementation in Phase 2 back-end work).

### 5. Testing / QA
- [ ] 5.1 Unit tests for repository logic: group creation, leave, Snap behaviour.
- [ ] 5.2 Integration test: create group, send disappearing Snap, ensure each user can view once.

### Relevant Files (to be updated continuously)
- `lib/src/features/messages/data/messaging_repository.dart` – group + Snap logic
- `lib/src/features/messages/data/conversation_model.dart` – schema
- `lib/src/features/messages/presentation/...` – UI
- `lib/src/features/messages/...` – tests
- `firestore.rules`, `firestore.indexes.json` – security & index updates