/// Main entry point for the SnapConnect application.
/// 
/// This file initializes Firebase and launches the app with Riverpod
/// state management integration.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'src/app/app.dart';

/// Main function that initializes Firebase and runs the application
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bool firebaseInitialized = false;
  
  try {
    // Silence verbose debug logs during development – comment out if needed.
    // debugPrint = (String? message, {int? wrapWidth}) {};

    debugPrint('Initializing Firebase…');

    // One-liner works across mobile, web, and desktop because
    // DefaultFirebaseOptions.currentPlatform now includes Linux.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Firebase initialization timed-out'),
    );

    // App Check (optional) – disabled in development to avoid emulator issues
    /*
    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
        webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('App Check init timed out – continuing without it');
          return;
        },
      );
    } catch (appCheckError) {
      debugPrint('App Check init failed: $appCheckError');
    }
    */

    firebaseInitialized = true;
    debugPrint('Firebase initialized ✅');
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
    debugPrint('Continuing with offline mode - some features may be limited');
    
    // Show user-friendly error message for network issues
    if (e.toString().contains('network') || 
        e.toString().contains('resolve host') ||
        e.toString().contains('timed out')) {
      debugPrint('Network connectivity issue detected - running in offline mode');
    }
  }
  
  // Run the app with Riverpod provider scope
  runApp(
    ProviderScope(
      overrides: [
        // Provide Firebase initialization status to the app
        _firebaseInitializedProvider.overrideWith((ref) => firebaseInitialized),
      ],
      child: const SnapConnectApp(),
    ),
  );
}

/// Provider to track Firebase initialization status
final _firebaseInitializedProvider = Provider<bool>((ref) => false);
