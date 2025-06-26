/// Camera repository for handling camera operations and permissions.
/// 
/// This repository encapsulates camera-related business logic including
/// permission management, file storage, and media capture operations.

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

/// Camera repository provider
final cameraRepositoryProvider = Provider<CameraRepository>((ref) {
  return CameraRepository();
});

/// Repository for camera operations
class CameraRepository {
  /// Check and request camera permissions
  Future<bool> requestCameraPermissions() async {
    try {
      final cameraStatus = await Permission.camera.request();
      final microphoneStatus = await Permission.microphone.request();
      
      return cameraStatus.isGranted && microphoneStatus.isGranted;
    } catch (e) {
      debugPrint('Error requesting camera permissions: $e');
      return false;
    }
  }

  /// Check if camera permissions are granted
  Future<bool> hasCameraPermissions() async {
    try {
      final cameraStatus = await Permission.camera.status;
      final microphoneStatus = await Permission.microphone.status;
      
      return cameraStatus.isGranted && microphoneStatus.isGranted;
    } catch (e) {
      debugPrint('Error checking camera permissions: $e');
      return false;
    }
  }

  /// Get the directory for storing captured media
  Future<Directory> getMediaDirectory() async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory mediaDir = Directory('${appDocDir.path}/media');
      
      if (!await mediaDir.exists()) {
        await mediaDir.create(recursive: true);
      }
      
      return mediaDir;
    } catch (e) {
      debugPrint('Error creating media directory: $e');
      rethrow;
    }
  }

  /// Generate a unique filename for captured media
  String generateFileName({required bool isVideo}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = isVideo ? 'mp4' : 'jpg';
    return 'snap_$timestamp.$extension';
  }

  /// Save captured photo to app directory
  Future<String> savePhoto(Uint8List photoData) async {
    try {
      final mediaDir = await getMediaDirectory();
      final fileName = generateFileName(isVideo: false);
      final file = File('${mediaDir.path}/$fileName');
      
      await file.writeAsBytes(photoData);
      return file.path;
    } catch (e) {
      debugPrint('Error saving photo: $e');
      rethrow;
    }
  }

  /// Save captured video to app directory
  Future<String> saveVideo(String videoPath) async {
    try {
      final mediaDir = await getMediaDirectory();
      final fileName = generateFileName(isVideo: true);
      final sourceFile = File(videoPath);
      final targetFile = File('${mediaDir.path}/$fileName');
      
      await sourceFile.copy(targetFile.path);
      return targetFile.path;
    } catch (e) {
      debugPrint('Error saving video: $e');
      rethrow;
    }
  }

  /// Delete a media file
  Future<void> deleteMediaFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting media file: $e');
    }
  }

  /// Get all saved media files
  Future<List<FileSystemEntity>> getSavedMedia() async {
    try {
      final mediaDir = await getMediaDirectory();
      final files = await mediaDir.list().toList();
      
      // Sort by creation time (newest first)
      files.sort((a, b) {
        final aStat = a.statSync();
        final bStat = b.statSync();
        return bStat.modified.compareTo(aStat.modified);
      });
      
      return files;
    } catch (e) {
      debugPrint('Error getting saved media: $e');
      return [];
    }
  }
} 