// Standardized error handling utilities for the application.
//
// This file provides consistent error handling patterns, logging,
// and user-friendly error messages throughout the app.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Standardized error handling utility class
class ErrorHandler {
  ErrorHandler._();

  /// Handle Firebase Auth exceptions and convert to user-friendly messages
  static String handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address. Please check your email or sign up.';
      case 'wrong-password':
        return 'Incorrect password. Please try again or reset your password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address. Please sign in instead.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment before trying again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      default:
        return 'Authentication failed: ${e.message ?? 'Unknown error occurred'}';
    }
  }

  /// Handle general exceptions and provide user-friendly messages
  static String handleGeneralException(Exception e) {
    final errorMessage = e.toString().replaceAll('Exception: ', '');

    // Handle specific known error patterns
    if (errorMessage.toLowerCase().contains('username')) {
      return errorMessage; // Username errors are already user-friendly
    }

    if (errorMessage.toLowerCase().contains('network') ||
        errorMessage.toLowerCase().contains('connection')) {
      return 'Network error. Please check your internet connection and try again.';
    }

    if (errorMessage.toLowerCase().contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (errorMessage.toLowerCase().contains('permission')) {
      return 'Permission denied. Please check your account permissions.';
    }

    // Return the original message if it's already user-friendly
    return errorMessage.isNotEmpty
        ? errorMessage
        : 'An unexpected error occurred. Please try again.';
  }

  /// Log errors in debug mode with consistent formatting
  static void logError(
    String operation,
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalInfo,
  }) {
    if (kDebugMode) {
      final buffer = StringBuffer();
      buffer.writeln('🔥 Error in $operation:');
      buffer.writeln('   Error: $error');

      if (additionalInfo != null && additionalInfo.isNotEmpty) {
        buffer.writeln('   Additional Info:');
        additionalInfo.forEach((key, value) {
          buffer.writeln('     $key: $value');
        });
      }

      if (stackTrace != null) {
        buffer.writeln('   Stack Trace:');
        buffer.writeln(stackTrace.toString());
      }

      debugPrint(buffer.toString());
    }
  }

  /// Log successful operations in debug mode
  static void logSuccess(
    String operation, {
    Map<String, dynamic>? additionalInfo,
  }) {
    if (kDebugMode) {
      final buffer = StringBuffer();
      buffer.writeln('✅ Success in $operation');

      if (additionalInfo != null && additionalInfo.isNotEmpty) {
        buffer.writeln('   Info:');
        additionalInfo.forEach((key, value) {
          buffer.writeln('     $key: $value');
        });
      }

      debugPrint(buffer.toString());
    }
  }

  /// Create a standardized exception with consistent formatting
  static Exception createException(String message, {String? operation}) {
    final fullMessage = operation != null
        ? 'Failed to $operation: $message'
        : message;
    return Exception(fullMessage);
  }
}
