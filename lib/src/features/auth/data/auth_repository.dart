/// Authentication repository that handles all authentication-related operations
/// using Firebase Authentication and Firestore for user data management.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  /// Stream of auth state changes
  Stream<User?> authStateChanges() => auth.authStateChanges();

  /// Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      // Normalize username to lowercase and trim whitespace
      final normalizedUsername = username.toLowerCase().trim();
      
      // Additional validation on the backend
      if (normalizedUsername.length < 3 || normalizedUsername.length > 30) {
        throw Exception('Username must be between 3 and 30 characters');
      }
      
      if (!RegExp(r'^[a-z0-9_]+$').hasMatch(normalizedUsername)) {
        throw Exception('Username can only contain lowercase letters, numbers, and underscores');
      }
      
      final querySnapshot = await firestore
          .collection('users')
          .where('username', isEqualTo: normalizedUsername)
          .limit(1)
          .get();
      
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      // Re-throw with more context if it's our validation error
      if (e.toString().contains('Username')) {
        rethrow;
      }
      throw Exception('Failed to check username availability: $e');
    }
  }

  /// Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // First check if username is available (this also validates format)
      final isAvailable = await isUsernameAvailable(username);
      if (!isAvailable) {
        throw Exception('Username is already taken. Please choose another.');
      }

      // First, verify reCAPTCHA
      await auth.setSettings(
        appVerificationDisabledForTesting: false, // Set to true only for testing
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
          username: username, // _createUserDocument will normalize it
        );
      } else {
        throw Exception('Failed to create user account');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // Catch any other errors and ensure proper error handling
      if (e.toString().contains('Username')) {
        rethrow;
      }
      throw Exception('Sign up failed: $e');
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // First, verify reCAPTCHA
      await auth.setSettings(
        appVerificationDisabledForTesting: false, // Set to true only for testing
      );

      return await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await auth.signOut();
  }

  /// Get user document from Firestore
  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserDocument(String uid) async {
    try {
      return await firestore.collection('users').doc(uid).get();
    } catch (e) {
      throw Exception('Failed to get user document: $e');
    }
  }

  /// Check if user has completed profile setup
  Future<bool> hasCompletedProfileSetup(String uid) async {
    try {
      final userDoc = await getUserDocument(uid);
      if (userDoc?.exists == true) {
        final data = userDoc!.data()!;
        final bio = data['bio'] as String?;
        final interestTags = data['interest_tags'] as List?;
        
        // Profile is complete if user has both bio and interest tags
        return bio != null && bio.isNotEmpty && 
               interestTags != null && interestTags.isNotEmpty;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to check profile setup status: $e');
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
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Create user document in Firestore
  Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String username,
  }) async {
    try {
      // Normalize username for storage
      final normalizedUsername = username.toLowerCase().trim();
      
      await firestore.collection('users').doc(uid).set({
        'email': email,
        'username': normalizedUsername,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'bio': '',
        'interest_tags': [],
      });
      
      // Log successful creation for debugging
      print('User document created successfully for UID: $uid, Username: $normalizedUsername');
    } catch (e) {
      print('Failed to create user document for UID: $uid, Error: $e');
      throw Exception('Failed to create user profile: $e');
    }
  }

  /// Handle Firebase Auth exceptions and return user-friendly error messages
  Exception _handleAuthException(FirebaseAuthException e) {
    print('Firebase Auth Error - Code: ${e.code}, Message: ${e.message}'); // Debug logging
    
    switch (e.code) {
      // Sign Up Errors
      case 'weak-password':
        return Exception('Password is too weak. Please use at least 6 characters with a mix of letters and numbers.');
      case 'email-already-in-use':
        return Exception('This email is already registered. Try signing in instead or use a different email.');
      case 'invalid-email':
        return Exception('Please enter a valid email address.');
      case 'operation-not-allowed':
        return Exception('Email/password sign-up is currently disabled. Please contact support.');
        
      // Sign In Errors
      case 'user-not-found':
        return Exception('No account found with this email. Please check your email or sign up for a new account.');
      case 'wrong-password':
        return Exception('Incorrect password. Please check your password and try again.');
      case 'invalid-credential':
        return Exception('Invalid email or password. Please check your credentials and try again.');
      case 'user-disabled':
        return Exception('This account has been disabled. Please contact support for assistance.');
        
      // Rate limiting
      case 'too-many-requests':
        return Exception('Too many failed attempts. Please wait a few minutes before trying again.');
        
      // Network issues
      case 'network-request-failed':
        return Exception('Network connection problem. Please check your internet connection and try again.');
        
      // Verification errors
      case 'invalid-verification-code':
        return Exception('The verification code is invalid. Please try again.');
      case 'invalid-verification-id':
        return Exception('The verification process failed. Please try again.');
        
      // Generic credential errors (covers the recaptcha error you saw)
      case 'invalid-login-credentials':
      case 'invalid-credential-error':
        return Exception('Invalid email or password. Please check your credentials and try again.');
        
      // Session/token errors
      case 'credential-already-in-use':
        return Exception('This credential is already associated with a different account.');
      case 'requires-recent-login':
        return Exception('Please sign in again to complete this action.');
        
      // Catch-all for unknown errors
      default:
        // Check if the error message contains specific keywords
        final message = e.message?.toLowerCase() ?? '';
        
        if (message.contains('credential') || message.contains('password') || message.contains('incorrect')) {
          return Exception('Invalid email or password. Please check your credentials and try again.');
        } else if (message.contains('email')) {
          return Exception('Email address issue. Please check your email and try again.');
        } else if (message.contains('network') || message.contains('connection')) {
          return Exception('Network connection problem. Please check your internet and try again.');
        } else {
          return Exception('Sign-in failed. Please check your email and password, then try again.');
        }
    }
  }
} 