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

  /// Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
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
          username: username,
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
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

  /// Create user document in Firestore
  Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String username,
  }) async {
    await firestore.collection('users').doc(uid).set({
      'email': email,
      'username': username,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'bio': '',
      'interest_tags': [],
    });
  }

  /// Handle Firebase Auth exceptions and return user-friendly error messages
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return Exception('The password provided is too weak.');
      case 'email-already-in-use':
        return Exception('An account already exists for that email.');
      case 'invalid-email':
        return Exception('The email address is not valid.');
      case 'operation-not-allowed':
        return Exception('Email/password accounts are not enabled.');
      case 'user-disabled':
        return Exception('This user has been disabled.');
      case 'user-not-found':
        return Exception('No user found for that email.');
      case 'wrong-password':
        return Exception('Wrong password provided.');
      case 'too-many-requests':
        return Exception('Too many sign-in attempts. Please try again later.');
      case 'network-request-failed':
        return Exception('Network error. Please check your connection.');
      case 'invalid-verification-code':
        return Exception('Invalid verification code.');
      case 'invalid-verification-id':
        return Exception('Invalid verification ID.');
      default:
        return Exception('An unknown error occurred: ${e.message}');
    }
  }
} 