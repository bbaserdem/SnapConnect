# Phase 0: Initial Project Setup

**Goal**: To establish a fully configured, reproducible development environment and deploy a minimal "Hello World" application to a device. This phase validates that all core components of our tech stack (Nix, Flutter, Firebase) are working together correctly.

---

## Key Tasks & Features

### 1. Environment Setup with Nix

-   **Description**: Configure the `flake.nix` file to provide a complete, declarative development environment.
-   **Steps**:
    1.  Initialize a new Nix flake in the project root.
    2.  Add Flutter, the Android SDK, and the required JDK as inputs.
    4.  Add `direnv` and `nix-direnv` integration for automatic shell activation.
    5.  Verify the environment by running `nix develop` and executing `flutter doctor`.

### 2. Flutter Project Initialization

-   **Description**: Create the initial Flutter application structure.
-   **Steps**:
    1.  Initialize a new Flutter project within the repository.
    2.  Clean up the default counter application code.
    3.  Organize the `lib/` directory according to our `project-rules.md` (creating `src/app`, `src/common`, `src/features`).

### 3. Firebase Project Integration

-   **Description**: Connect the Flutter application to a new Firebase project.
-   **Steps**:
    1.  Create a new project in the Firebase console.
    2.  Use the FlutterFire CLI (`flutterfire configure`) to automatically generate the necessary platform-specific configuration files for both Android and iOS.
    3.  Add the core `firebase_core` package to `pubspec.yaml`.
    4.  Initialize Firebase within the `main.dart` file.

### 4. "Hello World" Implementation

-   **Description**: Create a single screen to confirm the application builds and runs.
-   **Steps**:
    1.  Create a simple `HomePage` widget that displays the text "Hello World".
    2.  Set up basic navigation with `go_router` to show this page as the initial route.
    3.  Implement the `MaterialApp` with the theme settings from `theme-rules.md` (using the Deep Teal and Bright Orange color scheme).

### 5. Build and Deploy to Emulator

-   **Description**: Compile and run the application on both Android and iOS platforms to confirm the end-to-end setup.
-   **Steps**:
    1.  Launch an Android emulator.
    2.  Run `flutter run` and verify the app appears correctly.
    3.  Launch an iOS simulator.
    4.  Run `flutter run` again and verify the app appears correctly on iOS. 