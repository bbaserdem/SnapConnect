# Phase 1: Core Clone Development

**Goal**: Develop the core features of the Snapchat clone, creating a functional social media application with real-time messaging, stories, and basic AR capabilities, tailored for the body mod enthusiast community.

---

## Key Tasks & Features

### 1. User Authentication & Profile Management
- **Description**: Implement user sign-up, login, and profile management using Firebase Authentication and Firestore. This is the gateway for users to enter the app and personalize their experience.
- **Tech Stack**: `Firebase Auth`, `Firestore`, `Riverpod`, `go_router`, `Flutter Secure Storage`.
- **Steps**:
    1.  Configure Firebase Authentication for email/password.
    2.  Build responsive Sign Up and Log In screens using `TextField` and `FilledButton` components, adhering to `ui-rules.md`.
    3.  Use `Riverpod` to manage and listen to the global authentication state.
    4.  Create a `users` collection in Firestore to store public profile information, including `username`, `bio`, and specialized `interest_tags` (e.g., tattoos, piercings).
    5.  Design a Profile Setup screen as part of the onboarding flow where users select their interests.
    6.  Implement route guards with `go_router` to protect authenticated routes.

### 2. Main App Navigation & Structure
- **Description**: Build the main application shell with tab-based navigation as defined in `user-flow.md` to provide intuitive access to core features.
- **Tech Stack**: `go_router`, `Flutter`.
- **Steps**:
    1.  ✅ Implement a `ShellRoute` in `go_router` to host a persistent `NavigationBar` (the Material 3 bottom nav bar).
    2.  ✅ Define the five primary navigation destinations: Camera (default), Friends, Profile, Messages, and Stories.
    3.  ✅ Use appropriate icons for each tab, ensuring they meet the minimum 48x48dp touch target size.
    4.  ✅ Configure navigation to use icons only (no text labels) to avoid clutter.

**Implementation Notes:**
- Created `NavigationShell` widget to host the bottom navigation bar using Material 3 design
- Implemented `StatefulShellRoute.indexedStack` in go_router for proper tab management
- Created placeholder screens for all five main sections: Camera, Friends, Profile, Messages, and Stories
- Added Profile tab in the center position to provide easy access to user profile information
- Each screen includes appropriate UI elements and placeholder functionality with clear indicators for future implementation phases
- Navigation preserves state between tabs and provides smooth transitions
- Configured `labelBehavior: NavigationDestinationLabelBehavior.alwaysHide` to show icons only

### 3. Camera and Snap Creation
- **Description**: Implement the core functionality of capturing photos and videos, applying simple filters, and adding text overlays.
- **Tech Stack**: `CamerAwesome`, `tflite_flutter`, `Isolate`.
- **Steps**:
    1.  ✅ Integrate `CamerAwesome` to create a full-screen camera interface.
    2.  ✅ Implement tap-to-capture for photos and press-and-hold for videos.
    3.  🚧 Develop a basic filter system using `tflite_flutter`. For the MVP, this can be simple color adjustments or overlays. Run model inference in a separate `Isolate` to prevent UI lag.
    4.  ✅ After capture, navigate to an editing screen where users can add text overlays.
    5.  ✅ Implement a UI for setting the Snap's view duration (1-10 seconds).

**Implementation Notes:**
- Integrated `CamerAwesome` with full-screen camera interface and proper lifecycle management
- Implemented camera permissions handling with user-friendly error states
- Created camera state management using Riverpod for reactive UI updates
- Built snap editing screen with text overlays, positioning, and duration controls
- Added proper camera resource cleanup and performance optimizations
- Camera supports front/back switching, flash controls, and photo/video capture modes
- Navigation to editing screen works seamlessly with captured media
- Performance optimized to prevent UI blocking during camera operations

### 4. Real-time Messaging & Snaps
- **Description**: Develop the direct messaging feature for sending and receiving disappearing text and media-based Snaps.
- **Tech Stack**: `Firestore`, `Firebase Storage`, `Riverpod`, `Isar`.
- **Steps**:
    1.  Model chat conversations in Firestore. A message document can contain either text content or a reference to a Snap in Firebase Storage.
    2.  Build the Messages Tab UI with a reactive list of recent conversations using `ListItem` components.
    3.  Create the chat screen, displaying messages and handling real-time updates using `Firestore` streams and `Riverpod`.
    4.  Implement the logic to upload a Snap to `Firebase Storage` and send a message containing its reference.
    5.  Enforce the "disappearing" logic: delete the Firestore message and the associated media from Storage after the recipient views it.
    6.  Use `Isar` to cache recent conversations for faster initial loads and basic offline access.

### 5. Stories Feature
- **Description**: Implement the ability for users to post Snaps to their personal Story, visible to their friends for 24 hours.
- **Tech Stack**: `Firestore`, `Firebase Storage`.
- **Steps**:
    1.  Create a `stories` collection in Firestore. Each document represents an active story for a single user, containing an array of Snap references with timestamps.
    2.  On the "Send To" screen, include an option to "Post to My Story".
    3.  When a user posts, upload the media to `Firebase Storage` and add its reference to their story document in Firestore.
    4.  Build the Stories Tab UI to display a list of friends who have active stories, using `Card` components for previews.
    5.  Create a full-screen story viewer that automatically plays the Snaps from a selected user's story in sequence.
    6.  Use Firebase TTL policies on the `stories` collection to automatically delete story documents 24 hours after creation.

### 6. Friend Management System
- **Description**: Allow users to search for, add, and manage their list of friends.
- **Tech Stack**: `Firestore`, `Riverpod`.
- **Steps**:
    1.  Model friend relationships in Firestore (e.g., a `friends` subcollection on each user document containing friend IDs and statuses like `pending`, `accepted`).
    2.  Create the Friends Tab UI, showing the user's current friend list and pending requests.
    3.  Implement an "Add Friend" screen with a search bar (`TextField`).
    4.  Build a search function that queries the `users` collection by username.
    5.  Implement the business logic for sending, accepting, and rejecting friend requests.

### 7. Group Messaging
- **Description**: Extend the real-time messaging system to support group chats.
- **Tech Stack**: `Firestore`, `Firebase Storage`.
- **Steps**:
    1.  Update the Firestore schema to accommodate group conversations with a list of participant IDs.
    2.  Allow users to create new groups from the "Send To" screen by selecting multiple friends.
    3.  Adapt the chat UI to display sender information for messages within a group context.
    4.  Ensure Snaps sent to groups can be viewed by all members and handle view-state logic appropriately. 