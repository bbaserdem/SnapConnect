/// Camera state notifier for managing camera operations and state.
/// 
/// This notifier handles camera permissions, flash settings, camera switching,
/// and provides a reactive interface for camera operations.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'camera_repository.dart';

/// App camera state model
@immutable
class AppCameraState {
  const AppCameraState({
    this.hasPermissions = false,
    this.isInitialized = false,
    this.isLoading = false,
    this.flashMode = FlashMode.none,
    this.cameraAspectRatio = CameraAspectRatios.ratio_16_9,
    this.captureMode = CaptureMode.photo,
    required this.sensor,
    this.error,
  });

  final bool hasPermissions;
  final bool isInitialized;
  final bool isLoading;
  final FlashMode flashMode;
  final CameraAspectRatios cameraAspectRatio;
  final CaptureMode captureMode;
  final Sensor sensor;
  final String? error;

  AppCameraState copyWith({
    bool? hasPermissions,
    bool? isInitialized,
    bool? isLoading,
    FlashMode? flashMode,
    CameraAspectRatios? cameraAspectRatio,
    CaptureMode? captureMode,
    Sensor? sensor,
    String? error,
  }) {
    return AppCameraState(
      hasPermissions: hasPermissions ?? this.hasPermissions,
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      flashMode: flashMode ?? this.flashMode,
      cameraAspectRatio: cameraAspectRatio ?? this.cameraAspectRatio,
      captureMode: captureMode ?? this.captureMode,
      sensor: sensor ?? this.sensor,
      error: error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppCameraState &&
        other.hasPermissions == hasPermissions &&
        other.isInitialized == isInitialized &&
        other.isLoading == isLoading &&
        other.flashMode == flashMode &&
        other.cameraAspectRatio == cameraAspectRatio &&
        other.captureMode == captureMode &&
        other.sensor == sensor &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      hasPermissions,
      isInitialized,
      isLoading,
      flashMode,
      cameraAspectRatio,
      captureMode,
      sensor,
      error,
    );
  }
}

/// Camera state notifier
class CameraStateNotifier extends StateNotifier<AppCameraState> {
  CameraStateNotifier(this._cameraRepository) : super(AppCameraState(sensor: Sensor.position(SensorPosition.back)));

  final CameraRepository _cameraRepository;

  /// Initialize camera permissions and state
  Future<void> initialize() async {
            state = state.copyWith(isLoading: true, error: null, sensor: Sensor.position(SensorPosition.back));

    try {
      final hasPermissions = await _cameraRepository.hasCameraPermissions();
      
      if (!hasPermissions) {
        final granted = await _cameraRepository.requestCameraPermissions();
        if (!granted) {
          state = state.copyWith(
            isLoading: false,
            hasPermissions: false,
            error: 'Camera permissions are required to use this feature',
          );
          return;
        }
      }

      state = state.copyWith(
        hasPermissions: true,
        isInitialized: true,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize camera: ${e.toString()}',
      );
    }
  }

  /// Toggle flash mode
  void toggleFlash() {
    final newFlashMode = switch (state.flashMode) {
      FlashMode.none => FlashMode.on,
      FlashMode.on => FlashMode.auto,
      FlashMode.auto => FlashMode.none,
      _ => FlashMode.none,
    };
    
    state = state.copyWith(flashMode: newFlashMode);
  }

  /// Switch between front and back camera
  void switchCamera() {
    final newSensor = state.sensor.position == SensorPosition.back 
        ? Sensor.position(SensorPosition.front) 
        : Sensor.position(SensorPosition.back);
    state = state.copyWith(sensor: newSensor);
  }

  /// Toggle between photo and video capture mode
  void toggleCaptureMode() {
    final newMode = state.captureMode == CaptureMode.photo 
        ? CaptureMode.video 
        : CaptureMode.photo;
    state = state.copyWith(captureMode: newMode);
  }

  /// Clear any error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset camera state
  void reset() {
    state = AppCameraState(sensor: Sensor.position(SensorPosition.back));
  }
}

/// Camera state notifier provider
final cameraStateNotifierProvider = 
    StateNotifierProvider<CameraStateNotifier, AppCameraState>((ref) {
  final cameraRepository = ref.watch(cameraRepositoryProvider);
  return CameraStateNotifier(cameraRepository);
});

/// Helper provider to get flash icon based on current flash mode
final flashIconProvider = Provider<IconData>((ref) {
  final flashMode = ref.watch(cameraStateNotifierProvider.select((state) => state.flashMode));
  
  return switch (flashMode) {
    FlashMode.none => Icons.flash_off,
    FlashMode.on => Icons.flash_on,
    FlashMode.auto => Icons.flash_auto,
    _ => Icons.flash_off,
  };
});

/// Helper provider to get camera icon based on current sensor
final cameraIconProvider = Provider<IconData>((ref) {
  final sensor = ref.watch(cameraStateNotifierProvider.select((state) => state.sensor));
  return sensor.position == SensorPosition.back ? Icons.camera_rear : Icons.camera_front;
}); 