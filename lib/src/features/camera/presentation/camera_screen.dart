/// Camera screen for capturing photos and videos using CamerAwesome.
/// 
/// This screen serves as the main camera interface where users can
/// capture content, switch cameras, toggle flash, and navigate to editing.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:go_router/go_router.dart';

import '../../../config/constants.dart';
import '../../../common/widgets/camera_control_button.dart';
import '../../../common/widgets/camera_filter_button.dart';
import '../data/camera_state_notifier.dart' as app_camera;

/// Main camera screen widget
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize camera when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(app_camera.cameraStateNotifierProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cameraState = ref.watch(app_camera.cameraStateNotifierProvider);
    final flashIcon = ref.watch(app_camera.flashIconProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview or loading/error state
          if (cameraState.hasPermissions && cameraState.isInitialized)
            _buildCameraPreview(cameraState)
          else if (cameraState.isLoading)
            _buildLoadingView()
          else if (cameraState.error != null)
            _buildErrorView(cameraState.error!, theme)
          else
            _buildPermissionView(theme),
          
          // Top overlay controls
          Positioned(
            top: MediaQuery.of(context).padding.top + UIDimensions.mediumSpacing,
            left: UIDimensions.mediumSpacing,
            right: UIDimensions.mediumSpacing,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CameraControlButton(
                  icon: flashIcon,
                  onPressed: () {
                    ref.read(app_camera.cameraStateNotifierProvider.notifier).toggleFlash();
                  },
                ),
                CameraControlButton(
                  icon: Icons.settings,
                  onPressed: () {
                    // TODO: Open camera settings
                    _showSettingsDialog(context);
                  },
                ),
              ],
            ),
          ),
          
          // Bottom controls
          if (cameraState.hasPermissions && cameraState.isInitialized)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + UIDimensions.extraLargeSpacing,
              left: 0,
              right: 0,
              child: _buildBottomControls(cameraState),
            ),
        ],
      ),
    );
  }

  /// Build the camera preview using CamerAwesome
  Widget _buildCameraPreview(app_camera.AppCameraState cameraState) {
    return CameraAwesomeBuilder.awesome(
      saveConfig: SaveConfig.photoAndVideo(
        initialCaptureMode: cameraState.captureMode,
      ),
      sensorConfig: SensorConfig.single(
        sensor: cameraState.sensor,
        flashMode: cameraState.flashMode,
        aspectRatio: cameraState.cameraAspectRatio,
      ),
      enablePhysicalButton: true,
      onMediaTap: (mediaCapture) {
        // Navigate to edit screen after capture
        _navigateToEditScreen(mediaCapture);
      },
    );
  }

  /// Build loading view
  Widget _buildLoadingView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }

  /// Build error view
  Widget _buildErrorView(String error, ThemeData theme) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: UIDimensions.extraLargeIcon,
                color: Colors.red.withValues(alpha: ColorConstants.highOpacity),
              ),
              const SizedBox(height: 16),
              Text(
                'Camera Error',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: ColorConstants.almostOpaque),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.read(app_camera.cameraStateNotifierProvider.notifier).initialize();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build permission request view
  Widget _buildPermissionView(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                'Camera Access',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Grant camera permission to capture photos and videos',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: ColorConstants.almostOpaque),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.read(app_camera.cameraStateNotifierProvider.notifier).initialize();
                },
                child: const Text('Grant Permission'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build bottom controls section
  Widget _buildBottomControls(app_camera.AppCameraState cameraState) {
    return Column(
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
                  // TODO: Apply filter in future phase
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Filter ${index + 1} - Coming soon'),
                      duration: AnimationDurations.snackbar,
                    ),
                  );
                },
              );
            },
          ),
        ),
        
        const SizedBox(height: UIDimensions.largeSpacing),
        
        // Main capture controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Gallery button
            CameraControlButton(
              icon: Icons.photo_library,
              onPressed: () {
                // TODO: Open gallery/recent captures
                _showRecentCaptures(context);
              },
            ),
            
            // Main capture button
            CameraCaptureButton(
              onTap: () {
                // This will be handled by CamerAwesome's onMediaTap
              },
              onLongPress: () {
                // Switch to video mode for long press
                ref.read(app_camera.cameraStateNotifierProvider.notifier).toggleCaptureMode();
              },
            ),
            
            // Switch camera button
            CameraControlButton(
              icon: Icons.flip_camera_ios,
              onPressed: () {
                ref.read(app_camera.cameraStateNotifierProvider.notifier).switchCamera();
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Navigate to edit screen after capture
  void _navigateToEditScreen(MediaCapture mediaCapture) {
    // TODO: Navigate to edit screen with captured media
    context.push('/snap-edit', extra: mediaCapture);
  }

  /// Show camera settings dialog
  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Settings'),
        content: const Text('Camera settings will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show recent captures dialog
  void _showRecentCaptures(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recent Captures'),
        content: const Text('Gallery feature will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
} 