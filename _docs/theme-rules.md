# Theme Rules

This document defines the application's color, typography, and shape systems. Adhering to these rules will ensure a consistent, intentional, and modern aesthetic that aligns with our brand identity. The theme is built upon the principles of Material Design 3 and is designed to be energetic, modern, and motivating.

---

## 1. Color Scheme

Our color scheme is based on a primary color of **Deep Teal** and a vibrant **Bright Orange** accent. Using Flutter's `ColorScheme.fromSeed`, we will generate full tonal palettes for both light and dark modes. This ensures that all UI components are colored harmoniously and meet accessibility contrast requirements.

*   **Primary (Seed) Color**: Deep Teal (`#045D5D`)
*   **Secondary/Tertiary (Accent) Color**: Bright Orange (`#FF7043`)

### Light Theme

The light theme will feel airy, clean, and energizing.

*   **`primary`**: A vibrant shade of teal, used for key components like filled buttons and active indicators.
*   **`secondary`**: A complementary neutral tone.
*   **`tertiary`**: A vibrant shade of orange, used for prominent accents like floating action buttons or highlighted toggles.
*   **`surface` / `background`**: Clean, bright off-white colors to maximize readability and keep the focus on content.
*   **`on...` Colors**: Contrasting colors (typically black or dark gray) applied to text and icons on top of the primary, secondary, tertiary, surface, and background colors.

### Dark Theme

The dark theme is designed to be easy on the eyes in low-light conditions, with a focus on depth and contrast.

*   **`primary`**: A slightly desaturated, softer shade of teal that reduces eye strain while maintaining its identity.
*   **`secondary`**: A complementary dark neutral tone.
*   **`tertiary`**: A desaturated shade of orange that provides a vibrant but not overwhelmingly bright accent.
*   **`surface` / `background`**: Dark gray (not pure black) to reduce smearing on OLED screens and create a sense of depth.
*   **`on...` Colors**: Contrasting colors (typically white or light gray) for text and icons.

---

## 2. Typography

We will use the **Nunito** font family from Google Fonts for all text in the application. Its rounded terminals give it a friendly, approachable feel, while its excellent readability makes it suitable for a content-centric social app.

The Flutter `TextTheme` will be configured based on the Material 3 type scale. This provides a predefined set of text styles that create a clear and consistent typographic hierarchy.

*   **Font Family**: Nunito

*   **Type Scale Roles**:
    *   **Display**: Reserved for very large, short, and important text (e.g., on a splash screen).
    *   **Headline**: Best for short, high-emphasis text on-screen (e.g., screen titles in the `AppBar`).
    *   **Title**: For medium-emphasis text that is shorter than body text (e.g., `ListItem` titles, `Card` titles).
    *   **Body**: Used for all long-form text (e.g., chat messages, user bios, descriptions).
    *   **Label**: For small, utility text (e.g., button text, captions, navigation bar labels).

---

## 3. Shape

To achieve a soft and contemporary look, we will apply consistent corner rounding to our components. The Material 3 shape system defines styles for different component sizes.

*   **Component Shape System**:
    *   **Extra Small (`4dp` radius)**: `Chip`
    *   **Small (`8dp` radius)**: `ElevatedButton`, `TextField`
    *   **Medium (`12dp` radius)**: `Card`, `AlertDialog`
    *   **Large (`16dp` radius)**: `NavigationBar`
    *   **Extra Large (`28dp` radius)**: `Dialog` (when not full-screen) 