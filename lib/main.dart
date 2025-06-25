/// Main entry point for the SnapConnect application.
/// 
/// This file initializes Firebase and launches the app with Riverpod
/// state management integration.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'src/app/app.dart';

/// Main function that initializes Firebase and runs the application
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase only on supported platforms (not Linux)
    if (defaultTargetPlatform != TargetPlatform.linux) {
      debugPrint('Initializing Firebase...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize App Check with debug provider for development
      await FirebaseAppCheck.instance.activate(
        // Use debug provider for development
        androidProvider: AndroidProvider.debug,
        // Use debug provider for Apple platforms
        appleProvider: AppleProvider.debug,
        // Use debug provider for web
        webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      );

      debugPrint('Firebase initialized successfully');
    } else {
      debugPrint('Skipping Firebase initialization on Linux');
    }
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }
  
  // Run the app with Riverpod provider scope
  runApp(
    const ProviderScope(
      child: SnapConnectApp(),
    ),
  );
}
