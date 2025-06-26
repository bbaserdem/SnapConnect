/// Camera screen for capturing photos and videos.
/// 
/// This screen serves as the main camera interface where users can
/// capture content, apply filters, and create snaps.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/constants.dart';
import '../../../common/widgets/camera_control_button.dart';
import '../../../common/widgets/camera_filter_button.dart';

/// Main camera screen widget
class CameraScreen extends ConsumerWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview placeholder
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: UIDimensions.extraLargeIcon,
                    color: Colors.white.withValues(alpha: ColorConstants.highOpacity),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Camera',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to capture a photo\nHold to record a video',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: ColorConstants.almostOpaque),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          // Top overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + UIDimensions.mediumSpacing,
            left: UIDimensions.mediumSpacing,
            right: UIDimensions.mediumSpacing,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CameraControlButton(
                  icon: Icons.flash_off,
                  onPressed: () {
                    // TODO: Toggle flash
                  },
                ),
                CameraControlButton(
                  icon: Icons.settings,
                  onPressed: () {
                    // TODO: Open camera settings
                  },
                ),
              ],
            ),
          ),
          
          // Bottom controls
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + UIDimensions.extraLargeSpacing,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Filter options placeholder
                SizedBox(
                  height: UIDimensions.filterItemHeight,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: UIDimensions.mediumSpacing),
                    itemCount: AppConstants.cameraFilterCount,
                    itemBuilder: (context, index) {
                      return CameraFilterButton(
                        filterName: 'F${index + 1}',
                        onTap: () {
                          // Add visual feedback for filter selection
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Filter ${index + 1} selected'),
                              duration: AnimationDurations.snackbar,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: UIDimensions.largeSpacing),
                
                // Capture button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery button
                    CameraControlButton(
                      icon: Icons.photo_library,
                      onPressed: () {
                        // TODO: Open gallery
                      },
                    ),
                    
                    // Main capture button
                    CameraCaptureButton(
                      onTap: () {
                        // TODO: Capture photo
                        _showCaptureMessage(context);
                      },
                      onLongPress: () {
                        // TODO: Start video recording
                        _showCaptureMessage(context);
                      },
                    ),
                    
                    // Switch camera button
                    CameraControlButton(
                      icon: Icons.flip_camera_ios,
                      onPressed: () {
                        // TODO: Switch camera
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Shows a message when capture is attempted (placeholder functionality)
  void _showCaptureMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera functionality will be implemented in Phase 1.3'),
        duration: AnimationDurations.longSnackbar,
      ),
    );
  }
} 