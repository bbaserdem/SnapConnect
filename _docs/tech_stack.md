# Tech Stack

This document summarizes the decided technology stack for the project and outlines best practices, conventions, and common pitfalls for each component. These choices were made to prioritize development velocity for the MVP while ensuring scalability and compatibility with the NixOS development environment.

---

## Final Tech Stack

### Core Frameworks
*   **Application Framework**: Flutter
*   **Backend as a Service (BaaS)**: Firebase

---

### Application-Level Technologies

*   **State Management**: `Riverpod`
    *   **Usage and Considerations**:
        *   **Best Practices**: Keep providers small and focused on a single responsibility. Use `.autoDispose` and `family` modifiers to manage state lifecycle and prevent memory leaks. Prefer `StatelessWidget` combined with `ConsumerWidget` for UI, and create dedicated `Notifier` classes for complex business logic.
        *   **Conventions**: Name providers clearly based on the state they manage (e.g., `userProvider`, `feedProvider`). Use `ref.watch` to rebuild the UI when data changes, and `ref.read` for one-time reads within functions.
        *   **Pitfalls**: Avoid creating monolithic "god" providers that manage too much state. Be mindful that `.autoDispose` can cause state to be lost unexpectedly on screen transitions if not used carefully. Watch out for creating dependency cycles between providers.

*   **Navigation**: `go_router`
    *   **Usage and Considerations**:
        *   **Best Practices**: Centralize all route definitions in a single configuration file. Use named routes (`context.goNamed('routeName')`) to avoid magic strings in the code. Implement authentication and logic guards using the `redirect` feature. For persistent UI like a bottom nav bar, use `ShellRoute`.
        *   **Conventions**: Define route paths using kebab-case (e.g., `/user-profile`). Pass complex objects between routes using the `extra` parameter.
        *   **Pitfalls**: Managing state for nested navigators (e.g., tabs within a screen) can become complex. Deep linking with non-serializable data passed via `extra` can be tricky and may require custom logic.

*   **Local Database**: `Isar`
    *   **Usage and Considerations**:
        *   **Best Practices**: Define database schemas in dedicated files. Use indexes (`@Index()`) on fields that are frequently queried to boost performance. Perform all write operations within explicit transactions. Keep a single Isar instance open for the app's lifetime.
        *   **Conventions**: Use `isar.watch()` to create reactive UI components that automatically update when the underlying data changes.
        *   **Pitfalls**: The key limitation is its reliance on binary components, which may require specific configuration within our `flake.nix` file. Schema migrations are a manual process and must be handled carefully between app updates to avoid data loss.

---

### Feature-Specific Technologies

*   **Camera & AR**: `CamerAwesome` + `tflite_flutter`
    *   **Usage and Considerations**:
        *   **Best Practices**: To prevent UI "jank," run model inference on a separate Isolate (background thread). Initialize the `tflite` interpreter once and reuse it across frames. Use a `CustomPainter` to draw AR effects over the camera preview for best performance.
        *   **Conventions**: Package model files (`.tflite`) as assets in the `pubspec.yaml` file.
        *   **Pitfalls**: This is a DIY approach; achieving perfectly smooth, high-FPS effects will require more optimization than a commercial SDK. Performance will be CPU-bound, which may be a limitation on older devices.

*   **AI/ML Integration**: Firebase Functions + Vertex AI
    *   **Usage and Considerations**:
        *   **Best Practices**: Write functions in TypeScript for type safety. Specify the function's region to be close to your users to reduce latency. Configure memory and timeouts to balance performance and cost. Use the official `@google-cloud/vertexai` client library.
        *   **Conventions**: Use the Firebase Emulator Suite for local development of functions that interact with other Firebase services.
        *   **Pitfalls**: "Cold starts" can cause initial latency for infrequently used functions. This can be mitigated by setting a minimum number of instances, but this incurs cost. The initial setup of Vertex AI permissions and APIs can be complex.

---

### Development Environment

*   **Environment Management**: Nix Flakes
    *   **Usage and Considerations**:
        *   **Best Practices**: Always commit the `flake.lock` file to the repository to guarantee perfectly reproducible builds. Use `nix develop` to enter the development shell. For maximum convenience, integrate `direnv` with `use flake` to automatically load the environment upon entering the project directory.
        *   **Conventions**: Define all system-level dependencies (like `jdk`, `android-sdk`) required by Flutter within the `devShell` of `flake.nix`.
        *   **Pitfalls**: The learning curve for Nix can be steep. Debugging Nix expressions is a different skill set from application debugging. The local Nix store (`/nix/store`) can grow large, requiring periodic garbage collection (`nix-collect-garbage`).

---

# Suggested Tech Stack Recommendations

Based on the project overview and user flow, here are technology recommendations for the stack. The core framework is Flutter with a Firebase backend, and the development environment is NixOS. For each category, I've proposed an industry-standard option and a popular alternative.

---

## 1. State Management

Handles how application state is managed and passed around the widget tree. A good choice here is critical for scalability and maintainability.

**Proposal 1: Industry Standard - `Riverpod`**
*   **Description**: `Riverpod` is a modern, compile-safe state management library that improves upon the officially recommended `Provider`. It's highly flexible, testable, and eliminates the dependency on Flutter's widget tree for state access. This makes it easier to manage complex state, like user sessions, friend lists, and real-time message updates from Firebase.
*   **NixOS Compatibility**: Excellent. It's a pure Dart package managed by `pub`, which integrates smoothly into a Nix-based Flutter environment.

**Proposal 2: Popular Alternative - `BLoC`**
*   **Description**: `BLoC` (Business Logic Component) is a pattern that separates UI from business logic using streams. It's very popular for large, complex applications because it enforces a clear architecture, making the app highly scalable and testable. It can be more verbose than `Riverpod` but is extremely robust.
*   **NixOS Compatibility**: Excellent. Also a pure Dart package.

---

## 2. Camera and AR

Core to the Snapchat experience is the camera and the ability to apply filters.

**Proposal 1: Industry Standard - `camera` + `DeepAR`**
*   **Description**:
    *   **`camera`**: The official Flutter team package for controlling the device camera. It's the standard for basic functionality like taking pictures and recording videos.
    *   **`DeepAR`**: A commercial, high-performance AR SDK that specializes in face filters, effects, and masks. It's an industry standard for apps that need polished, Snapchat-like AR features. It has a dedicated Flutter SDK. This is the fastest way to get high-quality AR effects running.
*   **NixOS Compatibility**: The `camera` package is fine. `DeepAR` is a pre-compiled binary; its integration would need testing within the Nix environment, but it's generally platform-agnostic and should work as long as the Flutter build process can link it.

**Proposal 2: Popular Alternative - `CamerAwesome` + DIY with `TensorFlow Lite`**
*   **Description**:
    *   **`CamerAwesome`**: A powerful community-driven alternative to the official `camera` package, offering a richer feature set and a more streamlined API.
    *   **DIY with `TensorFlow Lite`**: This approach involves using `tflite_flutter` to run custom machine learning models for facial landmark detection. Once landmarks are detected, we can overlay our own graphics or effects using Flutter's standard drawing APIs. This offers maximum creative control and is lower cost, but it requires significantly more development effort and expertise in computer vision.
*   **NixOS Compatibility**: Excellent. All are open-source packages that work well with Nix.

---

## 3. AI/ML Integration

For RAG features like content recommendations, intelligent captions, and friend suggestions.

**Proposal 1: Industry Standard - Firebase Functions + Vertex AI**
*   **Description**: This is a powerful, server-side approach. The Flutter app sends requests (e.g., an image, user data) to **Firebase Functions**. These functions then leverage **Google Cloud's Vertex AI**, which has powerful generative models and tools for building RAG systems. This is highly scalable and allows for complex AI logic without bogging down the user's device.
*   **NixOS Compatibility**: Not applicable for the client-side, as this is a backend integration. The development workflow is unaffected.

**Proposal 2: Popular Alternative - Firebase Functions + Hugging Face / On-Device `tflite_flutter`**
*   **Description**: A more flexible, potentially lower-cost approach.
    *   **Server-side**: Use Firebase Functions to call open-source models hosted on a platform like **Hugging Face**. This gives access to a vast range of models.
    *   **On-device**: For simpler tasks that require low latency (like identifying objects in an image to suggest tags), run lightweight models directly on the device using `tflite_flutter`. This is fast and works offline. This hybrid approach balances power and efficiency.
*   **NixOS Compatibility**: `tflite_flutter` and its dependencies can be managed within the Nix environment. Backend choice doesn't affect the local setup.

---

## 4. Navigation

For managing routes and screens within the application.

**Proposal 1: Industry Standard - `go_router`**
*   **Description**: The officially recommended package by the Flutter team. `go_router` provides a declarative, URL-based API for navigation that simplifies routing logic, especially for complex apps with deep linking requirements (e.g., opening a specific story from a notification).
*   **NixOS Compatibility**: Excellent. A standard `pub` package.

**Proposal 2: Popular Alternative - `AutoRoute`**
*   **Description**: A popular community package that uses code generation to create a fully type-safe routing setup. It reduces boilerplate by generating the necessary routing logic for you, which can prevent common errors and speed up development.
*   **NixOS Compatibility**: Excellent. The code generation step integrates well with standard Flutter build commands.

---

## 5. Local Database

For caching data like friend lists, messages, and user settings to improve performance and provide offline support.

**Proposal 1: Industry Standard - `sqflite`**
*   **Description**: A wrapper around SQLite, the tried-and-true embedded database on iOS and Android. It's perfect for storing structured, relational data and is extremely stable and well-supported.
*   **NixOS Compatibility**: Good. It may require `sqlite` as a system dependency in the Nix shell environment, which is straightforward to add.

**Proposal 2: Popular Alternative - `Isar`**
*   **Description**: A fast, modern NoSQL database built from the ground up for Flutter. It's fully cross-platform, requires minimal boilerplate, and offers impressive performance. Its object-based API feels very natural in Dart and is a great fit for the kind of data we'll be storing (user profiles, stories, etc.).
*   **NixOS Compatibility**: Good. `Isar` has some binary components, but they are typically downloaded by the build script. This should work fine in a Nix environment, but we'd confirm during setup.
*   **Decision Note**: We've selected `Isar` for its development speed. We acknowledge its binary components may require specific configuration in the NixOS environment. If build issues arise, the first step will be to investigate how to properly link Isar's binaries within our Nix setup.

---

## 6. Development Environment

For ensuring a reproducible development environment on NixOS.

**Proposal 1: Industry Standard - `Nix Flakes`**
*   **Description**: Flakes are the modern, standard way to manage dependencies in Nix projects. A `flake.nix` file would define a completely hermetic development shell, pinning the exact versions of Flutter, the Android SDK, and any other system-level dependencies. This guarantees that every developer has the exact same environment, eliminating "works on my machine" issues.
*   **NixOS Compatibility**: Native. This is the recommended approach for any serious Nix-based project.

**Proposal 2: Popular Alternative - `shell.nix`**
*   **Description**: The traditional way of defining a development environment in Nix. A `shell.nix` file is used to pull dependencies from the user's configured Nix channels. It's simpler to write than a flake and is not as reproducible because it depends on the state of the user's channels.
*   **NixOS Compatibility**: Native. It's the older but still very common method.

---

## Stack Summary

This table clarifies how common development concepts map to the Flutter ecosystem and our chosen stack.

| Category            | Web Development Example | Flutter Equivalent                    | Our Choice       |
| ------------------- | ----------------------- | ------------------------------------- | ---------------- |
| **Framework**       | React, Vue, Svelte      | Flutter                               | **Flutter**      |
| **Build Tool**      | Vite, Webpack           | `flutter` CLI (built-in)              | **(included)**   |
| **Styling**         | CSS, Tailwind, Sass     | Widget properties & composition (Dart) | **(included)**   |
| **State Management**| Redux, Zustand, Pinia   | Riverpod, BLoC, Provider              | **Riverpod**     |
| **Real-time**       | Socket.io, Supabase     | Firebase, AppWrite                    | **Firebase**     |

</rewritten_file> 