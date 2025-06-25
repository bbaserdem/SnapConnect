# SnapConnect

SnapConnect is a social media application for body modification enthusiasts, built with Flutter and Firebase.

## Features

- User authentication with email/password
- Real-time messaging and photo sharing
- Profile customization with interest tags
- Story sharing with 24-hour expiration
- Friend management system

## Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / VS Code with Flutter extensions
- Firebase project
- For Android development:
  - Android SDK version 35 or higher
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

## Development

1. Start an emulator or connect a physical device

2. Run the app:
   ```bash
   flutter run
   ```

## Testing

Run tests with:
```bash
flutter test
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
