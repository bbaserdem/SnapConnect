/// Authentication repository that handles all authentication-related operations
/// using Firebase Authentication and Firestore for user data management.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../common/utils/error_handler.dart';
import '../../../config/constants.dart';

/// Provider for the AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});

/// Repository class that handles all authentication operations
class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository({
    required this.auth,
    required this.firestore,
  });

  /// Check network connectivity
  Future<bool> _hasNetworkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult.any((result) => 
        result != ConnectivityResult.none
      );
    } catch (e) {
      // If connectivity check fails, assume we have connectivity
      return true;
    }
  }

  /// Stream of auth state changes
  Stream<User?> authStateChanges() => auth.authStateChanges();

  /// Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      // Normalize username to lowercase and trim whitespace
      final normalizedUsername = username.toLowerCase().trim();
      
      // Additional validation on the backend
      if (normalizedUsername.length < AppConstants.minUsernameLength || 
          normalizedUsername.length > AppConstants.maxUsernameLength) {
        throw ErrorHandler.createException(
          'Username must be between ${AppConstants.minUsernameLength} and ${AppConstants.maxUsernameLength} characters',
          operation: 'validate username',
        );
      }
      
      if (!RegExp(r'^[a-z0-9_]+$').hasMatch(normalizedUsername)) {
        throw ErrorHandler.createException(
          'Username can only contain lowercase letters, numbers, and underscores',
          operation: 'validate username format',
        );
      }
      
      final querySnapshot = await firestore
          .collection('users')
          .where('username', isEqualTo: normalizedUsername)
          .limit(1)
          .get();
      
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      // Re-throw with more context if it's our validation error
      if (e.toString().contains('Username') || e.toString().contains('validate username')) {
        rethrow;
      }
      
      ErrorHandler.logError('check username availability', e, additionalInfo: {
        'username': username,
      });
      
      throw ErrorHandler.createException(
        'Unable to verify username availability. Please try again.',
        operation: 'check username availability',
      );
    }
  }

  /// Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    try {
      // First check if username is available (this also validates format)
      final isAvailable = await isUsernameAvailable(username);
      if (!isAvailable) {
        throw Exception('Username is already taken. Please choose another.');
      }

      // Disable reCAPTCHA verification for development/testing
      await auth.setSettings(
        appVerificationDisabledForTesting: true, // Disabled for development
      );

      // Create the user with email and password
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create the user document in Firestore
      if (userCredential.user != null) {
        await _createUserDocument(
          uid: userCredential.user!.uid,
          email: email,
          username: username,
          displayName: displayName,
        );
        
        ErrorHandler.logSuccess('user sign up', additionalInfo: {
          'uid': userCredential.user!.uid,
          'email': email,
          'username': username,
        });
      } else {
        throw ErrorHandler.createException(
          'Authentication succeeded but user account was not created properly',
          operation: 'create user account',
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      ErrorHandler.logError('sign up with email and password', e, additionalInfo: {
        'email': email,
        'username': username,
      });
      throw Exception(ErrorHandler.handleFirebaseAuthException(e));
    } catch (e) {
      // Catch any other errors and ensure proper error handling
      if (e.toString().contains('Username') || e.toString().contains('validate username')) {
        rethrow;
      }
      
      ErrorHandler.logError('sign up process', e, additionalInfo: {
        'email': email,
        'username': username,
      });
      
      if (e is Exception) {
        throw Exception(ErrorHandler.handleGeneralException(e));
      } else {
        throw ErrorHandler.createException(
          'An unexpected error occurred during sign up. Please try again.',
          operation: 'sign up',
        );
      }
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    try {
      // Disable reCAPTCHA verification for development/testing
      await auth.setSettings(
        appVerificationDisabledForTesting: true, // Disabled for development
      );

      final userCredential = await auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: trimmedPassword,
      );
      
      ErrorHandler.logSuccess('user sign in', additionalInfo: {
        'uid': userCredential.user?.uid,
        'email': trimmedEmail,
      });
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' || e.code == 'invalid-login-credentials') {
        throw Exception('Incorrect email or password. Please try again.');
      }
      
      ErrorHandler.logError('sign in with email and password', e, additionalInfo: {
        'email': trimmedEmail,
      });
      throw Exception(ErrorHandler.handleFirebaseAuthException(e));
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await auth.signOut();
  }

  /// Get user document from Firestore
  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserDocument(String uid) async {
    try {
      final document = await firestore.collection('users').doc(uid).get();
      
      ErrorHandler.logSuccess('get user document', additionalInfo: {
        'uid': uid,
        'exists': document.exists,
      });
      
      return document;
    } catch (e) {
      ErrorHandler.logError('get user document', e, additionalInfo: {
        'uid': uid,
      });
      
      throw ErrorHandler.createException(
        'Unable to retrieve user profile. Please try again.',
        operation: 'get user document',
      );
    }
  }

  /// Check if user has completed profile setup
  Future<bool> hasCompletedProfileSetup(String uid) async {
    try {
      // Add timeout to prevent hanging on network issues
      final userDoc = await getUserDocument(uid).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw ErrorHandler.createException(
            'Network timeout - check your connection',
            operation: 'check profile setup status',
          );
        },
      );
      
      if (userDoc?.exists == true) {
        final data = userDoc!.data()!;
        final bio = data['bio'] as String?;
        final interestTags = data['interest_tags'] as List?;
        
        // Profile is complete if user has both bio and interest tags
        final isComplete = bio != null && bio.isNotEmpty && 
                          interestTags != null && interestTags.isNotEmpty;
        
        ErrorHandler.logSuccess('check profile setup status', additionalInfo: {
          'uid': uid,
          'isComplete': isComplete,
          'hasBio': bio != null && bio.isNotEmpty,
          'hasInterestTags': interestTags != null && interestTags.isNotEmpty,
        });
        
        return isComplete;
      }
      
      ErrorHandler.logSuccess('check profile setup status', additionalInfo: {
        'uid': uid,
        'userDocExists': false,
        'isComplete': false,
      });
      
      return false;
    } catch (e) {
      ErrorHandler.logError('check profile setup status', e, additionalInfo: {
        'uid': uid,
      });
      
      // For network/timeout errors, assume profile setup is complete
      // to prevent blocking user experience
      if (e.toString().contains('timeout') || 
          e.toString().contains('network') ||
          e.toString().contains('resolve host')) {
        debugPrint('Network issue detected - assuming profile setup NOT complete');
        return false;
      }
      
      throw ErrorHandler.createException(
        'Unable to check profile setup status. Please try again.',
        operation: 'check profile setup status',
      );
    }
  }

  /// Update user profile information
  Future<void> updateUserProfile({
    required String uid,
    required String bio,
    required List<String> interestTags,
  }) async {
    try {
      await firestore.collection('users').doc(uid).set({
        'bio': bio,
        'interest_tags': interestTags,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      ErrorHandler.logSuccess('update user profile', additionalInfo: {
        'uid': uid,
        'bioLength': bio.length,
        'tagCount': interestTags.length,
        'tags': interestTags,
      });
    } catch (e) {
      ErrorHandler.logError('update user profile', e, additionalInfo: {
        'uid': uid,
        'bioLength': bio.length,
        'tagCount': interestTags.length,
      });
      
      throw ErrorHandler.createException(
        'Unable to save profile changes. Please try again.',
        operation: 'update user profile',
      );
    }
  }

  /// Create user document in Firestore
  Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String username,
    required String displayName,
  }) async {
    // Normalize username for storage
    final normalizedUsername = username.toLowerCase().trim();
    
    try {
      await firestore.collection('users').doc(uid).set({
        'email': email,
        'username': normalizedUsername,
        'display_name': displayName.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'bio': '',
        'interest_tags': [],
      });
      
      ErrorHandler.logSuccess('create user document', additionalInfo: {
        'uid': uid,
        'email': email,
        'username': normalizedUsername,
      });
    } catch (e) {
      ErrorHandler.logError('create user document', e, additionalInfo: {
        'uid': uid,
        'email': email,
        'username': normalizedUsername,
      });
      
      throw ErrorHandler.createException(
        'Unable to create user profile. Please try signing up again.',
        operation: 'create user profile',
      );
    }
  }


} 