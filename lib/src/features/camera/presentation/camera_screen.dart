// Camera screen for capturing photos and videos using CamerAwesome.
//
// This screen serves as the main camera interface where users can
// capture content, switch cameras, toggle flash, and navigate to editing.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:go_router/go_router.dart';

import '../../../config/constants.dart';
import '../data/camera_state_notifier.dart' as app_camera;

/// Main camera screen widget
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  bool _hasInitialized = false;
  bool _isDisposed = false;

  @override
  bool get wantKeepAlive => true; // Keep alive to prevent recreation

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  /// Initialize camera with proper error handling
  void _initializeCamera() {
    if (_hasInitialized || _isDisposed) return;

    // Initialize camera after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasInitialized && !_isDisposed) {
        _hasInitialized = true;
        ref.read(app_camera.cameraStateNotifierProvider.notifier).initialize();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);

    // Only dispose camera if we actually initialized it
    if (_hasInitialized) {
      ref.read(app_camera.cameraStateNotifierProvider.notifier).dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (!mounted || !_hasInitialized || _isDisposed) return;

    // Only handle app lifecycle changes, not tab navigation
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // Camera will be paused automatically by CamerAwesome
        break;
      case AppLifecycleState.resumed:
        // Camera will be resumed automatically by CamerAwesome
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Handle app termination
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    if (_isDisposed) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final cameraState = ref.watch(app_camera.cameraStateNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildCameraBody(cameraState, theme),
    );
  }

  /// Build camera body with proper state management
  Widget _buildCameraBody(
    app_camera.AppCameraState cameraState,
    ThemeData theme,
  ) {
    // Show camera preview when properly initialized
    if (cameraState.hasPermissions &&
        cameraState.isInitialized &&
        !_isDisposed) {
      return _buildCameraPreview(cameraState);
    }

    // Show loading state
    if (cameraState.isLoading) {
      return _buildLoadingView();
    }

    // Show error state
    if (cameraState.error != null) {
      return _buildErrorView(cameraState.error!, theme);
    }

    // Show permission request
    return _buildPermissionView(theme);
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
      onMediaCaptureEvent: (event) {
        // Handle media capture events
        if (event.status == MediaCaptureStatus.success && mounted) {
          // Navigate to edit screen
          context.push('/snap-edit', extra: event);
        }
      },
    );
  }

  /// Build loading view
  Widget _buildLoadingView() {
    return const ColoredBox(
      color: Colors.black,
      child: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  /// Build error view
  Widget _buildErrorView(String error, ThemeData theme) {
    return ColoredBox(
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
                  color: Colors.white.withValues(
                    alpha: ColorConstants.almostOpaque,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (mounted && !_isDisposed) {
                    ref
                        .read(app_camera.cameraStateNotifierProvider.notifier)
                        .initialize();
                  }
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
    return ColoredBox(
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
                color: Colors.white.withValues(
                  alpha: ColorConstants.highOpacity,
                ),
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
                  color: Colors.white.withValues(
                    alpha: ColorConstants.almostOpaque,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (mounted && !_isDisposed) {
                    ref
                        .read(app_camera.cameraStateNotifierProvider.notifier)
                        .initialize();
                  }
                },
                child: const Text('Grant Permission'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
