# UI/UX Rules

This document outlines the visual and interaction design guidelines for the application, including the theme, component styles, and core interaction principles. To ensure a modern, consistent, and intuitive user experience, we will adhere to Google's **Material Design 3** (M3) system.

---

## 1. Core Principles

These principles will guide all UI/UX decisions, ensuring the app is both beautiful and functional, with a clear focus on the needs of body mod enthusiasts.

*   **Clarity and Simplicity**: The interface must prioritize content. The camera screen—the app's entry point—should remain uncluttered, encouraging immediate creation. All UI elements must have a clear purpose to avoid distracting the user.
*   **Intuitive Interaction**: User actions should feel natural. We will leverage common mobile interaction patterns (taps, swipes, long-presses) and provide immediate, predictable feedback using Material Design's built-in effects like ripples.
*   **Visual Hierarchy**: A clear hierarchy will guide the user's focus. We will use elevation, color, and typography to distinguish between primary actions (like capturing a Snap) and secondary ones (like accessing settings).
*   **Consistency**: Components and patterns will be reused throughout the application. A button or icon should look and behave the same way on every screen. This builds user confidence and makes the app easier to learn.

---

## 2. Theme

This section defines the application's color, typography, and shape systems. Adhering to these rules will ensure a consistent, intentional, and modern aesthetic that aligns with our brand identity. The theme is built upon the principles of Material Design 3 and is designed to be energetic, modern, and motivating.

### 2.1. Color Scheme

Our color scheme is based on a primary color of **Deep Teal** and a vibrant **Bright Orange** accent. Using Flutter's `ColorScheme.fromSeed`, we will generate full tonal palettes for both light and dark modes. This ensures that all UI components are colored harmoniously and meet accessibility contrast requirements.

*   **Primary (Seed) Color**: Deep Teal (`#045D5D`)
*   **Secondary/Tertiary (Accent) Color**: Bright Orange (`#FF7043`)

#### Light Theme

The light theme will feel airy, clean, and energizing.

*   **`primary`**: A vibrant shade of teal, used for key components like filled buttons and active indicators.
*   **`secondary`**: A complementary neutral tone.
*   **`tertiary`**: A vibrant shade of orange, used for prominent accents like floating action buttons or highlighted toggles.
*   **`surface` / `background`**: Clean, bright off-white colors to maximize readability and keep the focus on content.
*   **`on...` Colors**: Contrasting colors (typically black or dark gray) applied to text and icons on top of the primary, secondary, tertiary, surface, and background colors.

#### Dark Theme

The dark theme is designed to be easy on the eyes in low-light conditions, with a focus on depth and contrast.

*   **`primary`**: A slightly desaturated, softer shade of teal that reduces eye strain while maintaining its identity.
*   **`secondary`**: A complementary dark neutral tone.
*   **`tertiary`**: A desaturated shade of orange that provides a vibrant but not overwhelmingly bright accent.
*   **`surface` / `background`**: Dark gray (not pure black) to reduce smearing on OLED screens and create a sense of depth.
*   **`on...` Colors**: Contrasting colors (typically white or light gray) for text and icons.

### 2.2. Typography

We will use the **Nunito** font family from Google Fonts for all text in the application. Its rounded terminals give it a friendly, approachable feel, while its excellent readability makes it suitable for a content-centric social app.

The Flutter `TextTheme` will be configured based on the Material 3 type scale. This provides a predefined set of text styles that create a clear and consistent typographic hierarchy.

*   **Font Family**: Nunito

*   **Type Scale Roles**:
    *   **Display**: Reserved for very large, short, and important text (e.g., on a splash screen).
    *   **Headline**: Best for short, high-emphasis text on-screen (e.g., screen titles in the `AppBar`).
    *   **Title**: For medium-emphasis text that is shorter than body text (e.g., `ListItem` titles, `Card` titles).
    *   **Body**: Used for all long-form text (e.g., chat messages, user bios, descriptions).
    *   **Label**: For small, utility text (e.g., button text, captions, navigation bar labels).

### 2.3. Shape

To achieve a soft and contemporary look, we will apply consistent corner rounding to our components. The Material 3 shape system defines styles for different component sizes.

*   **Component Shape System**:
    *   **Extra Small (`4dp` radius)**: `Chip`
    *   **Small (`8dp` radius)**: `ElevatedButton`, `TextField`
    *   **Medium (`12dp` radius)**: `Card`, `AlertDialog`
    *   **Large (`16dp` radius)**: `NavigationBar`
    *   **Extra Large (`28dp` radius)**: `Dialog` (when not full-screen)

---

## 3. Layout and Spacing

A consistent spatial system makes the UI feel balanced and orderly.

*   **Grid System**: All layouts will be aligned to an 8dp grid.
*   **Spacing**: Margins and padding between elements will use increments of 8dp (e.g., 8dp, 16dp, 24dp) to maintain a consistent rhythm.
*   **Touch Targets**: All interactive elements (buttons, icons, list items) must have a minimum touch target size of 48x48dp to ensure accessibility and prevent accidental taps.

---

## 4. Component Guidelines

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

## 5. Motion and Animation

Motion should be used purposefully to guide the user and provide feedback.

*   **Screen Transitions**: We will use `go_router` to manage screen transitions. Transitions should be fluid and consistent with the Material Design specification (e.g., fade-through, shared axis).
*   **Micro-interactions**: Subtle animations on UI elements (e.g., a button press, an icon state change) will be used to provide delight and confirm user actions. We will avoid excessive or distracting animations. 