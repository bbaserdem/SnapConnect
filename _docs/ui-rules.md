# UI Rules

This document outlines the visual and interaction design guidelines for the application. To ensure a modern, consistent, and intuitive user experience, we will adhere to Google's **Material Design 3** (M3) system. Our use of Flutter provides first-class support for implementing these principles.

---

## 1. Core Principles

These principles will guide all UI/UX decisions, ensuring the app is both beautiful and functional, with a clear focus on the needs of body mod enthusiasts.

*   **Clarity and Simplicity**: The interface must prioritize content. The camera screen—the app's entry point—should remain uncluttered, encouraging immediate creation. All UI elements must have a clear purpose to avoid distracting the user.
*   **Intuitive Interaction**: User actions should feel natural. We will leverage common mobile interaction patterns (taps, swipes, long-presses) and provide immediate, predictable feedback using Material Design's built-in effects like ripples.
*   **Visual Hierarchy**: A clear hierarchy will guide the user's focus. We will use elevation, color, and typography to distinguish between primary actions (like capturing a Snap) and secondary ones (like accessing settings).
*   **Consistency**: Components and patterns will be reused throughout the application. A button or icon should look and behave the same way on every screen. This builds user confidence and makes the app easier to learn.

---

## 2. Layout and Spacing

A consistent spatial system makes the UI feel balanced and orderly.

*   **Grid System**: All layouts will be aligned to an 8dp grid.
*   **Spacing**: Margins and padding between elements will use increments of 8dp (e.g., 8dp, 16dp, 24dp) to maintain a consistent rhythm.
*   **Touch Targets**: All interactive elements (buttons, icons, list items) must have a minimum touch target size of 48x48dp to ensure accessibility and prevent accidental taps.

---

## 3. Component Guidelines

We will use standard Material 3 components from the Flutter framework to build our UI. This ensures consistency and leverages Flutter's built-in support for theming and accessibility.

*   **Navigation**:
    *   **Primary Navigation**: The main sections of the app (Snap, Friends, Messages, Stories) will be accessible via a `NavigationBar` (the M3 bottom navigation bar).
    *   **Screen-Level Navigation**: `AppBar` will be used at the top of screens that are not the main camera view (e.g., Settings, Add Friends). It will contain the screen title, back button, and contextual actions.

*   **Buttons**: We will use the standard Material button types, each for a specific purpose:
    *   `ElevatedButton`: For high-emphasis actions, like "Save Profile".
    *   `FilledButton`: For primary, high-emphasis actions within a view, like "Send".
    *   `OutlinedButton`: For medium-emphasis actions that are secondary to a filled button.
    *   `TextButton`: For low-emphasis actions, often used in dialogs or cards (e.g., "Cancel", "See More").
    *   `IconButton`: For actions represented by an icon, such as the AI Ideas (lightbulb) or settings icons.

*   **Dialogs and Popups**:
    *   `AlertDialog`: For critical information or confirmations that require a user decision (e.g., "Allow Camera Access?").
    *   `Dialog`: For more complex interactions, such as the AI-generated content ideas popup, which may contain a list of suggestions.

*   **Content Display**:
    *   `Card`: To group related content and separate it visually from its surroundings. This will be used for friend recommendations, story previews, and items in a settings list.
    *   `ListItem`: To display rows of information in a uniform way, such as in the friends list, chat list, or stories list.

*   **Input**:
    *   `TextField`: For all user text input, including login/signup forms, user bios, and captions for Snaps.

---

## 4. Motion and Animation

Motion should be used purposefully to guide the user and provide feedback.

*   **Screen Transitions**: We will use `go_router` to manage screen transitions. Transitions should be fluid and consistent with the Material Design specification (e.g., fade-through, shared axis).
*   **Micro-interactions**: Subtle animations on UI elements (e.g., a button press, an icon state change) will be used to provide delight and confirm user actions. We will avoid excessive or distracting animations. 