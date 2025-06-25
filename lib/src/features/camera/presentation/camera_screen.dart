/// Camera screen for capturing photos and videos.
/// 
/// This screen serves as the main camera interface where users can
/// capture content, apply filters, and create snaps.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Main camera screen widget
class CameraScreen extends ConsumerWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                    size: 120,
                    color: Colors.white.withValues(alpha: 0.7),
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
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          // Top overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.flash_off, color: Colors.white),
                  onPressed: () {
                    // TODO: Toggle flash
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    // TODO: Open camera settings
                  },
                ),
              ],
            ),
          ),
          
          // Bottom controls
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 32,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Filter options placeholder
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 8, // Increased count to make scrolling more apparent
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // Add visual feedback for filter selection
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Filter ${index + 1} selected'),
                              duration: const Duration(milliseconds: 800),
                            ),
                          );
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'F${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Capture button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery button
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.photo_library,
                        color: Colors.white,
                      ),
                    ),
                    
                    // Main capture button
                    GestureDetector(
                      onTap: () {
                        // TODO: Capture photo
                        _showCaptureMessage(context);
                      },
                      onLongPress: () {
                        // TODO: Start video recording
                        _showCaptureMessage(context);
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: colorScheme.primary,
                            width: 4,
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 32,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    
                    // Switch camera button
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.flip_camera_ios,
                        color: Colors.white,
                      ),
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
        duration: Duration(seconds: 2),
      ),
    );
  }
} 