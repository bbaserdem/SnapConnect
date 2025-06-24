---
title: Project Rules
description: A comprehensive guide to the project's structure, conventions, and coding standards.
version: 1.0.0
---

# Project Rules

## 1. Introduction

We are building an AI-first codebase, which means it needs to be modular, scalable, and easy to understand. The file structure should be highly navigable, and the code should be well-organized and easy to read.

This document outlines the directory structure, file naming conventions, and coding standards that all contributors must follow. These rules are designed to ensure consistency, maintainability, and compatibility with modern AI development tools.

---

## 2. Directory Structure

The project follows a feature-based architecture to promote modularity and scalability. All Flutter source code resides within the `lib/` directory.

```
/
├── .vscode/          # VSCode settings
├── _docs/            # Project documentation (overview, user-flow, rules, etc.)
├── android/          # Android-specific project files
├── functions/        # Firebase Cloud Functions (TypeScript)
│   ├── src/
│   └── package.json
├── ios/              # iOS-specific project files
├── lib/              # Main Flutter application source code
│   ├── src/
│   │   ├── app/                # Core app setup (routing, themes, app entry)
│   │   ├── common/             # Shared widgets, constants, and utilities
│   │   │   ├── widgets/
│   │   │   └── utils/
│   │   ├── features/           # Feature-based modules (e.g., auth, chat, stories)
│   │   │   └── <feature_name>/
│   │   │       ├── data/       # Data layer: models, repositories, data sources
│   │   │       ├── domain/     # Business logic (optional, for complex features)
│   │   │       └── presentation/ # UI layer: screens, widgets, state notifiers
│   │   └── main.dart         # App entry point
├── test/             # Automated tests
├── flake.nix         # Nix flake for reproducible environment
├── flake.lock        # Nix lock file
└── pubspec.yaml      # Flutter project dependencies
```

---

## 3. File Naming Conventions

To maintain a clean and predictable file structure, all files and directories must follow these conventions:

*   **Format**: `snake_case` (lowercase words connected by underscores).
*   **Feature Directories**: Named after the feature they contain (e.g., `lib/src/features/user_auth/`).
*   **File Suffixes**: File names should be descriptive and end with a suffix indicating their role.
    *   Screens: `_screen.dart` (e.g., `login_screen.dart`)
    *   Widgets: `_widget.dart` (e.g., `primary_button_widget.dart`)
    *   Repositories: `_repository.dart` (e.g., `auth_repository.dart`)
    *   Notifiers/Providers: `_notifier.dart` or `_provider.dart` (e.g., `auth_state_notifier.dart`)
    *   Models: `_model.dart` (e.g., `user_model.dart`)

---

## 4. Coding Standards

These standards ensure our code is clean, consistent, and easy for both humans and AI to parse.

### 4.1. General Principles

*   **Concise and Technical**: Write code that is direct and efficient.
*   **Functional Patterns**: Use functional and declarative programming patterns. Avoid classes for simple logic; use top-level functions.
*   **Immutability**: Data models and state classes should be immutable.
*   **No Magic Strings**: Use constants for route names, keys, tags, and other recurring strings.
*   **Error Handling**: Throw specific, descriptive errors instead of returning `null` or fallback values.
*   **Variable Naming**: Use descriptive names with auxiliary verbs for booleans (e.g., `isLoading`, `hasCompleted`).

### 4.2. Documentation and Comments

*   **File Headers**: Every `.dart` file must begin with a comment explaining its contents and purpose.
*   **Function Documentation**: All public functions and classes must have `dartdoc` comments (`///`). Document the function's purpose, its parameters (`@param`), and what it returns (`@return`).
*   **Implementation Comments**: Use `//` for comments within functions to explain complex, non-obvious logic.

### 4.3. Code Health

*   **Linting**: All code must pass analysis by the linter (`flutter analyze`).
*   **Formatting**: All code must be formatted with `dart format`. This should be automated with a pre-commit hook if possible.
*   **File Size**: To maximize compatibility with modern AI tools, files should not exceed 500 lines. Refactor large files into smaller, more focused components.

### 4.4. State Management (`Riverpod`)

*   **Granularity**: Keep providers small and focused on a single responsibility.
*   **Lifecycle**: Use `.autoDispose` to clean up state when it's no longer needed.
*   **Naming**: Name providers clearly and consistently, ending with `...Provider` (e.g., `userProvider`).

---

## 5. Commit Message Format

Commit messages must follow the **Conventional Commits** specification. This creates an explicit and easily readable commit history.

**Format**: `<type>(<scope>): <subject>`

*   **`type`**: `feat` (new feature), `fix` (bug fix), `docs` (documentation), `style` (formatting), `refactor`, `test`, `chore`.
*   **`scope`** (optional): The part of the codebase affected (e.g., `auth`, `camera`, `chat`).
*   **`subject`**: A concise description of the change.

**Example**: `feat(auth): implement user sign-up screen` 