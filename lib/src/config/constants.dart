// Application constants and configuration values.
//
// This file centralizes all hardcoded values, magic numbers, and configuration
// constants to improve maintainability and consistency across the app.

/// UI dimension constants
class UIDimensions {
  UIDimensions._();

  // Button sizes
  static const double smallButtonSize = 50.0;
  static const double mediumButtonSize = 60.0;
  static const double largeButtonSize = 80.0;

  // Border radius
  static const double smallBorderRadius = 12.0;
  static const double mediumBorderRadius = 16.0;
  static const double largeBorderRadius = 25.0;
  static const double extraLargeBorderRadius = 30.0;
  static const double circleBorderRadius = 40.0;

  // Spacing
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;

  // Icon sizes
  static const double smallIcon = 24.0;
  static const double mediumIcon = 32.0;
  static const double largeIcon = 48.0;
  static const double extraLargeIcon = 120.0;

  // List item heights
  static const double filterItemHeight = 80.0;
  static const double filterItemWidth = 60.0;

  // Borders
  static const double thinBorder = 1.0;
  static const double mediumBorder = 2.0;
  static const double thickBorder = 4.0;
}

/// Animation duration constants
class AnimationDurations {
  AnimationDurations._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration snackbar = Duration(milliseconds: 800);
  static const Duration longSnackbar = Duration(seconds: 2);
}

/// App-specific constants
class AppConstants {
  AppConstants._();

  // Camera filter count
  static const int cameraFilterCount = 8;

  // Username validation
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;

  // Story duration (24 hours in seconds)
  static const int storyDurationSeconds = 24 * 60 * 60;

  // Snap view durations
  static const int minSnapDuration = 1;
  static const int maxSnapDuration = 10;
}

/// Color constants with opacity values
class ColorConstants {
  ColorConstants._();

  static const double lowOpacity = 0.1;
  static const double mediumOpacity = 0.3;
  static const double highOpacity = 0.7;
  static const double almostOpaque = 0.8;
}

/// Asset paths
class AssetPaths {
  AssetPaths._();

  // TODO: Add asset paths when assets are added
  // static const String logoPath = 'assets/images/logo.png';
}

/// Network constants
class NetworkConstants {
  NetworkConstants._();

  // TODO: Add API endpoints and network configuration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
