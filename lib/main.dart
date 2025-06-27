/// Main entry point for the SnapConnect application.
/// 
/// This file initializes Firebase and launches the app with Riverpod
/// state management integration.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;

import 'firebase_options.dart';
import 'src/app/app.dart';

/// Main function that initializes Firebase and runs the application
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bool firebaseInitialized = false;
  
  try {
    // Initialize Firebase on all platforms.
    if (Platform.isLinux) {
      debugPrint('Initializing Firebase for Linux (using web options)...');

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.web,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Firebase initialization timed out - check network connection');
        },
      );

      firebaseInitialized = true;
      debugPrint('Firebase initialized successfully (Linux)');

    } else {
      debugPrint('Initializing Firebase...');
      
      // Add timeout to prevent hanging on network issues
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Firebase initialization timed out - check network connection');
        },
      );

      // Initialize App Check with debug provider for development
      // DISABLED FOR DEVELOPMENT - Causes network issues in emulator
      /*
      try {
        await FirebaseAppCheck.instance.activate(
          // Use debug provider for development
          androidProvider: AndroidProvider.debug,
          // Use debug provider for Apple platforms
          appleProvider: AppleProvider.debug,
          // Use debug provider for web
          webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
        ).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('App Check initialization timed out - continuing without it');
            return;
          },
        );
      } catch (appCheckError) {
        debugPrint('App Check initialization failed: $appCheckError');
        // Continue without App Check for development
      }
      */
      debugPrint('App Check disabled for development');

      firebaseInitialized = true;
      debugPrint('Firebase initialized successfully');
    }
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
