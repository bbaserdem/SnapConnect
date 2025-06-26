// Reusable camera filter button widget.
//
// This widget provides a consistent styling for camera filter buttons
// in the filter selection list.

import 'package:flutter/material.dart';
import '../../config/constants.dart';

/// A reusable camera filter button with consistent styling
class CameraFilterButton extends StatelessWidget {
  /// Creates a camera filter button
  const CameraFilterButton({
    required this.filterName,
    required this.onTap,
    this.isSelected = false,
    super.key,
  });

  /// The name/label of the filter
  final String filterName;

  /// Callback when the filter is tapped
  final VoidCallback onTap;

  /// Whether this filter is currently selected
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: UIDimensions.filterItemWidth,
        height: UIDimensions.filterItemWidth,
        margin: const EdgeInsets.only(right: UIDimensions.smallSpacing * 1.5),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(
                  alpha: ColorConstants.mediumOpacity,
                )
              : Colors.white.withValues(alpha: ColorConstants.lowOpacity),
          borderRadius: BorderRadius.circular(
            UIDimensions.extraLargeBorderRadius,
          ),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.white.withValues(alpha: ColorConstants.mediumOpacity),
            width: isSelected
                ? UIDimensions.mediumBorder
                : UIDimensions.thinBorder,
          ),
        ),
        child: Center(
          child: Text(
            filterName,
            style: TextStyle(
              color: isSelected ? theme.colorScheme.primary : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
