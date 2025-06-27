# SnapConnect

SnapConnect is a social media application for body modification enthusiasts, built with Flutter and Firebase.

## Features

- **User Authentication & Profile Management**: Secure sign-up and login with Firebase. Users can set up profiles with a username, bio, and specialized interest tags (e.g., tattoos, piercings).
- **Main App Navigation**: Intuitive tab-based navigation for Camera, Friends, Profile, Messages, and Stories.
- **Camera and Snap Creation**: Capture photos and videos. Apply basic filters and add text overlays. Snaps can have a view duration from 1-10 seconds.
- **Real-time Messaging**: Send and receive disappearing text and media-based Snaps in one-on-one chats.
- **Group Messaging**: Create and participate in group chats with friends.
- **Stories**: Post Snaps to a personal Story, visible to friends for 24 hours.
- **Friend Management**: Search for, add, and manage friends.

## Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / VS Code with Flutter extensions
- Firebase project
- For Android development:
  - Android SDK version 34 or higher
  - Android Studio
- For iOS development:
  - Xcode
  - CocoaPods

## Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/snapconnect.git
   cd snapconnect
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Firebase Configuration:
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication (Email/Password)
   - Enable Cloud Firestore
   - Enable Firebase Storage
   - Enable App Check

4. Add platform-specific Firebase configuration:
   
   For Android:
   - In Firebase Console, register your Android app with package name `com.example.snapconnect`
   - Download `google-services.json`
   - Place it in `android/app/` directory (this file is gitignored)

   For iOS:
   - In Firebase Console, register your iOS app
   - Download `GoogleService-Info.plist`
   - Place it in `ios/Runner/` directory (this file is gitignored)

5. Update Android SDK version:
   - Open `android/app/build.gradle`
   - Set `compileSdk = 35`

## Security Notes

This project follows security best practices:
- Firebase configuration files (`google-services.json` and `GoogleService-Info.plist`) are not committed to version control
- API keys are restricted to specific services and platforms
- App Check is enabled to prevent unauthorized API access

## Quick Start

### For Nix

The project is configured to use the Nix package manager.

#### With Direnv

If direnv is set up, run `direnv allow`, and dev shell will be entered automatically.

#### With just NIx

```bash
nix develop
```

### Development with Emulator
```bash
direnv allow                              # Load NixOS development environment
emulator-dev -avd snapconnect_emulator   # Start emulator with smooth cameras
flutter run                              # Run the app
```

### For Real Camera Testingwith Emulator (Not Recommended)
```bash
optimize-webcam                          # Set webcam to emulator-friendly settings
emulator-camera -avd snapconnect_emulator # Start with real webcam (choppy)
flutter run                              # Run the app
restore-webcam                           # Restore webcam for video calls
```

## Development

1. Start an emulator or connect a physical device (see [Testing section](#camera--emulator-testing) for optimized workflows)

2. Run the app:
   ```bash
   flutter run
   ```

## Testing

### Unit Tests
Run unit tests with:
```bash
flutter test
```

### Camera & Emulator Testing

This project includes optimized scripts for different testing scenarios with camera functionality.

#### Prerequisites for NixOS Users
If you're using NixOS, enter the development shell:
```bash
direnv allow  # First time only
# The shell will load automatically with all tools
```

#### Available Testing Scripts

| Script | Purpose | Camera Type | Performance |
|--------|---------|-------------|------------|
| `emulator-dev` | Development & UI testing | Emulated | ⚡ Excellent |
| `emulator-camera` | Real camera testing | Real webcam | ⚠️ Choppy |
| `setup-physical-device` | Physical device setup | Device camera | 🚀 Native |

#### Webcam Management Scripts

| Script | Resolution | Use Case |
|--------|------------|----------|
| `webcam-minimal` | 320x240 @ 15fps | Emulator testing |
| `optimize-webcam` | 640x480 @ 30fps | Emulator (better quality) |
| `restore-webcam` | 1280x720 @ 30fps | Video calls (recommended) |
| `webcam-ultra` | 1920x1080 @ 30fps | High-quality video calls |


#### Performance Notes

- **Emulated cameras**: Perfect for UI development, filter testing, and general app flow
- **Real webcam in emulator**: Functional but choppy due to QEMU virtualization overhead
- **Physical device**: Best performance for camera-intensive features and real-world testing

#### Troubleshooting

**Camera app crashes:**
- Ensure emulator has cameras configured (`hw.camera.back = emulated`)
- Kill and restart emulator after configuration changes

**Choppy camera performance:**
- Use emulated cameras for development
- Switch to physical device for performance-critical testing
- Use minimal webcam settings with `webcam-minimal`

**Build issues:**
- Verify Android SDK 34 is installed
- Check `compileSdk = 34` in `android/app/build.gradle`
- Ensure Flutter and dependencies are up to date

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
