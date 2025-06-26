// Reusable camera control button widget.
//
// This widget provides a consistent styling for camera control buttons
// throughout the camera interface, eliminating code duplication.

import 'package:flutter/material.dart';
import '../../config/constants.dart';

/// A reusable camera control button with consistent styling
class CameraControlButton extends StatelessWidget {
  /// Creates a camera control button
  const CameraControlButton({
    required this.icon,
    required this.onPressed,
    this.size = CameraControlButtonSize.small,
    this.backgroundColor,
    this.iconColor = Colors.white,
    super.key,
  });

  /// The icon to display in the button
  final IconData icon;

  /// Callback when the button is pressed
  final VoidCallback? onPressed;

  /// The size of the button
  final CameraControlButtonSize size;

  /// Background color of the button (defaults to semi-transparent white)
  final Color? backgroundColor;

  /// Color of the icon
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final double buttonSize = _getButtonSize();
    final double iconSize = _getIconSize();
    final double borderRadius = buttonSize / 2;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color:
              backgroundColor ??
              Colors.white.withValues(alpha: ColorConstants.lowOpacity),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: Colors.white.withValues(alpha: ColorConstants.mediumOpacity),
            width: UIDimensions.thinBorder,
          ),
        ),
        child: Icon(icon, size: iconSize, color: iconColor),
      ),
    );
  }

  /// Get button size based on the size enum
  double _getButtonSize() {
    switch (size) {
      case CameraControlButtonSize.small:
        return UIDimensions.smallButtonSize;
      case CameraControlButtonSize.medium:
        return UIDimensions.mediumButtonSize;
      case CameraControlButtonSize.large:
        return UIDimensions.largeButtonSize;
    }
  }

  /// Get icon size based on the button size
  double _getIconSize() {
    switch (size) {
      case CameraControlButtonSize.small:
        return UIDimensions.smallIcon;
      case CameraControlButtonSize.medium:
        return UIDimensions.smallIcon;
      case CameraControlButtonSize.large:
        return UIDimensions.mediumIcon;
    }
  }
}

/// Specialized camera control button for the main capture functionality
class CameraCaptureButton extends StatelessWidget {
  /// Creates a camera capture button
  const CameraCaptureButton({
    required this.onTap,
    required this.onLongPress,
    super.key,
  });

  /// Callback when the button is tapped (photo capture)
  final VoidCallback? onTap;

  /// Callback when the button is long pressed (video recording)
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: UIDimensions.largeButtonSize,
        height: UIDimensions.largeButtonSize,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(UIDimensions.circleBorderRadius),
          border: Border.all(
            color: colorScheme.primary,
            width: UIDimensions.thickBorder,
          ),
        ),
        child: Icon(
          Icons.camera_alt,
          size: UIDimensions.mediumIcon,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}

/// Enum for button sizes
enum CameraControlButtonSize { small, medium, large }
