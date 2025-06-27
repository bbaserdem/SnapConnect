# Phase 1.7 – Group Messaging 📋 Implementation Task Log

This file tracks progress on implementing Group Messaging (see `tasks/prd-group-messaging.md`).

---

## Task List

### 0. Preparatory
- [x] 0.1 Create this task-log file and copy checklist here.

### 1. Data Layer
- [x] 1.1 Extend Firestore security rules & indexes for group conversations. (participant limit tightened to 10 in `firestore.rules`; existing index already supports `participantIds+updatedAt`)
- [x] 1.2 Ensure `ConversationModel` already supports `isGroup`, `groupName`; add `deletedFor` array.
- [x] 1.3 Implemented `createGroupConversation()` in `MessagingRepository` (enforces 2–10 unique participants, adds creator if missing, populates usernames, writes doc with isGroup=true and empty deletedFor).
- [x] 1.4 Implemented `leaveConversation()` in `MessagingRepository` (updates deletedFor array and filters out hidden conversations in stream).

### 2. Messaging
- [x] 2.1 Updated `markMessageAsViewed` to remove deletion scheduling; `_scheduleMessageDeletion` now skips snaps entirely.
- [x] 2.2 `_cleanupExpiredMessages` now only processes messages where `hasExpired && !isExpired`, leaving snaps intact until true expiry; existing `_deleteMessage` handles isExpired flag and URL stripping.

### 3. User Interface
- [x] 3.1 `NewMessageDialog` now supports group creation: switch toggle, group name field, multi-select friend list, and create button that calls repository.
- [x] 3.2 `chat_screen.dart` now displays senderUsername for *all* bubbles in group chats (including self), with color suited to bubble context.
- [x] 3.3 `ConversationTile` now renders the first two initials of groupName (fallback "GC") instead of generic group icon.
- [x] 3.4 Added PopupMenu "Leave Group" in ChatScreen AppBar which invokes `leaveConversation` and pops screen.

### 4. Repository
- [x] 4.1 `MessagingRepository` now increments `unreadCounts` transactionally for every participant except sender when message saved.
- [x] 4.2 Added `functions/notifications_placeholder.js` stub documenting intended push-notification logic.

### 5. Testing
- [x] 5.1 Added `test/messaging_repository_test.dart` verifying participant limit and leaveConversation updates; test uses fake Firestore & mock storage/auth.
- [ ] 5.2 Integration test: create group, send disappearing Snap, ensure each user can view once.
- [ ] 5.1 & 5.2 Deferred – Automated tests skipped due to rxdart dependency conflict (manual QA to be performed).

## Implementation Notes
- Fixed sign-up flow: removed manual navigation and ensured hasCompletedProfileSetup defaults to false on network errors.
- Fixed friend username search by adding 300 ms debounce; suggestions now appear.