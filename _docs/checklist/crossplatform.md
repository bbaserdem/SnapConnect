# Cross-Platform Firebase Migration Checklist

> Goal: make SnapConnect run on Linux desktop **and** mobile without duplicating code.
> Strategy: keep official FlutterFire plugins for Android/iOS, use pure-Dart `firebase_dart` on Web & Linux via conditional imports.

## 1 – Wrapper Pattern
1. Add tiny wrapper files per Firebase area
   - `lib/firebase_wrappers/firestore_stub.dart`
   - `lib/firebase_wrappers/firestore_web_linux.dart`
   - `lib/firebase_wrappers/auth_stub.dart`
   - `lib/firebase_wrappers/auth_web_linux.dart`
   - `lib/firebase_wrappers/storage_stub.dart`
   - `lib/firebase_wrappers/storage_web_linux.dart`
2. Replace every direct `cloud_firestore`, `firebase_auth`, `firebase_storage` import with the conditional form:

```dart
import 'package:snapconnect/firebase_wrappers/firestore_stub.dart'
    if (dart.library.html) 'package:snapconnect/firebase_wrappers/firestore_web_linux.dart'
    if (dart.library.io)  'package:snapconnect/firebase_wrappers/firestore_stub.dart' as ff;
```
3. Prefix all Firestore/Auth/Storage API calls with the alias `ff.` (or corresponding alias).
4. Keep mobile initialisation unchanged; Linux/Web already uses `DefaultFirebaseOptions.web`.

## 2 – Files that reference Firebase today

### Firestore Imports
- `lib/src/features/profile/presentation/profile_screen.dart`
- `lib/src/features/messages/data/messaging_repository.dart`
- `lib/src/features/messages/data/conversation_model.dart`
- `lib/src/features/messages/data/message_model.dart`
- `lib/src/features/auth/data/auth_repository.dart`
- `lib/src/features/auth/data/user_model.dart`

### Auth Imports
- `lib/src/features/messages/data/messaging_repository.dart`
- `lib/src/features/messages/presentation/messages_screen.dart`
- `lib/src/features/auth/data/auth_state_notifier.dart`
- `lib/src/features/auth/data/auth_repository.dart`
- `lib/src/common/utils/error_handler.dart`

### Storage Imports
- `lib/src/features/messages/data/messaging_repository.dart`

## 3 – Migration Steps
- [ ] Create wrapper files
- [ ] Update **messaging** feature first (repository & models)
- [ ] Verify Android build ✅
- [ ] Verify Linux build ✅
- [ ] Migrate Auth layer
- [ ] Migrate remaining Firestore usages
- [ ] Migrate Storage usages (snap uploads)
- [ ] Final pass: search for any leftover direct imports
- [ ] Update CI/tests

---
After each tick, run `flutter run -d linux` **and** an Android build to catch issues early. 