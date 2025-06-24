# User Flow

This document outlines the user journey for the Snapchat clone, focusing on the experience of a body mod enthusiast.
The flow covers onboarding, content creation, sharing, and interaction with AI-driven features.

---

## 1. Onboarding

The primary goal of onboarding is to get the user set up and ready to create and share content.

1.  **Launch App**: User opens the app for the first time.
2.  **Sign Up / Log In**: User is presented with options to sign up or log in. The signup process will ask for basic information like name, username, password, and birthday.
3.  **Profile Setup**:
    *   The user selects tags relevant to their interests (e.g., tattoos, piercings, heavy mods, implants, gender affirming, plastic surgery).
    *   The user can optionally add a profile picture and a short bio.
4.  **Permissions**: The app requests necessary permissions: Camera, Microphone, Notifications, and Contacts (for friend finding).
5.  **Landing Screen**: After onboarding, the user lands on the main Camera screen, ready to create content.

---

## 2. Core User Journey: The Content Loop

This section describes the primary loop of creating, sharing, and consuming content.

### 2.1. Main Application Navigation

The main application interface is organized into a series of tabs for easy navigation between key features:

*   **Snap Tab**: The default view, which opens directly into the camera for immediate content creation.
*   **Friends Tab**: Allows users to view their current friends list and search for new friends to add.
*   **Messages Tab**: A central hub for viewing and sending direct messages. Group chats are also managed within this tab.
*   **Stories Tab**: A dedicated section for viewing stories shared by other users.

### 2.2. Creating a Snap (Photo/Video)

1.  **Open Camera**: The app opens directly to the camera view.
3.  **Capture Content**: User can tap to take a photo or press and hold to record a video.
4.  **Apply Effects**: User can swipe to browse and apply simple AR filters and camera effects.
5.  **Edit and Enhance**:
    *   After capturing, the user enters an edit screen where they can add text.
    *   **AI-Powered Suggestions**: A button is available for the user to opt-in to intelligent captions and tags. This process runs in the background to avoid blocking the UI, and the generated content is appended to any manual captions. For now, personalized content generation is limited to these automatic captions and tags.
6.  **Set Timer**: User can set how long the snap will be visible to friends.

### 2.3. Sharing Content

Once a snap is created, the user chooses how to share it.

1.  **Select Audience**: From the "Send To" screen, the user can select:
    *   **My Story**: Posts the snap to their public or friends-only story for 24 hours.
    *   **Specific Friends**: Sends the snap as a direct, disappearing message.
    *   **Groups**: Shares the snap in a group chat.
2.  **Send**: User hits the send button to distribute the content.

### 2.4. Consuming Content

Users consume content from their friends and the wider community.

1.  **Viewing Direct Snaps**:
    *   Users get notifications for new snaps.
    *   They can view them from their chat list. The message disappears after viewing.
2.  **Watching Stories**:
    *   Users can view friend stories from a dedicated Stories screen.
    *   Stories are available for 24 hours.
3.  **Interacting with Group Chats**:
    *   Users can view snaps and text messages in group chats.

---

## 3. Social & Community Features

This section covers how users build and manage their social network.

### 3.1. Friend Management

1.  **Adding Friends**: Users can add friends by searching for a username, adding from phone contacts, or using Snapcodes (if this feature is cloned).
2.  **AI Friend Recommendations**: Context-aware friend and content recommendations appear in the "Add Friends" menu.
    *   **For Regular Users**: When the search bar is empty, the menu is populated with suggested friends.

### 3.2. Content Discovery

*   **Assumption**: Beyond friends' stories, there will be a way to discover content from other users, likely through the AI recommendations mentioned above.
*   **Clarification**: There will be, but it's beyond the scope of the app for now. We will add it into the future features list.

---

## 4. Future Features

This section lists features that are planned for future releases but are out of scope for the initial build.

*   **Content Discovery Page**: A dedicated section for discovering content from creators the user doesn't follow.
*   **AI-Generated Story Outlines**: Advanced AI feature to generate multi-snap story outlines based on user prompts.
*   **Drawings and Stickers**: Additional creative tools for editing snaps.

This user flow provides a foundational structure for the application. The questions highlighted indicate areas where more specific product decisions are needed to fully define the user journey, especially around the integration of AI features. 