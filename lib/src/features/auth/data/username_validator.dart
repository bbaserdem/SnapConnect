/// Utility class for username validation
/// Provides consistent validation logic across the application

class UsernameValidator {
  static const int minLength = 3;
  static const int maxLength = 30;
  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
  static final RegExp _normalizedUsernameRegex = RegExp(r'^[a-z0-9_]+$');

  /// Validate username format (case-insensitive)
  static String? validateFormat(String username) {
    if (username.isEmpty) {
      return 'Please enter a username';
    }
    
    if (username.length < minLength) {
      return 'Username must be at least $minLength characters';
    }
    
    if (username.length > maxLength) {
      return 'Username must be less than $maxLength characters';
    }
    
    if (!_usernameRegex.hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    
    return null; // Valid
  }

  /// Validate normalized username (lowercase only)
  static String? validateNormalizedFormat(String username) {
    final normalized = username.toLowerCase().trim();
    
    if (normalized.length < minLength || normalized.length > maxLength) {
      return 'Username must be between $minLength and $maxLength characters';
    }
    
    if (!_normalizedUsernameRegex.hasMatch(normalized)) {
      return 'Username can only contain lowercase letters, numbers, and underscores';
    }
    
    return null; // Valid
  }

  /// Normalize username for storage/comparison
  static String normalize(String username) {
    return username.toLowerCase().trim();
  }

  /// Check if username is valid format
  static bool isValidFormat(String username) {
    return validateFormat(username) == null;
  }
} 