# Final Tech Stack

This document summarizes the decided technology stack for the project and outlines best practices, conventions, and common pitfalls for each component. These choices were made to prioritize development velocity for the MVP while ensuring scalability and compatibility with the NixOS development environment.

---

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