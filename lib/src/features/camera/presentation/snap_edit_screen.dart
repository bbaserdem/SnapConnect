// Snap editing screen for adding text overlays and setting view duration.
//
// This screen allows users to edit their captured snaps by adding text,
// setting view duration, and choosing how to share their content.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:video_player/video_player.dart';

import '../../../config/constants.dart';

/// Snap edit screen widget
class SnapEditScreen extends ConsumerStatefulWidget {
  const SnapEditScreen({required this.mediaCapture, super.key});

  final dynamic mediaCapture; // This will be the event from onMediaCaptureEvent

  @override
  ConsumerState<SnapEditScreen> createState() => _SnapEditScreenState();
}

class _SnapEditScreenState extends ConsumerState<SnapEditScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  VideoPlayerController? _videoController;

  double _textX = 0.5;
  double _textY = 0.5;
  int _snapDuration = 3; // Default 3 seconds
  Color _textColor = Colors.white;
  double _textSize = 24.0;
  bool _isTextMode = false;

  @override
  void initState() {
    super.initState();
    _initializeMedia();
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  /// Initialize media (video player if it's a video)
  void _initializeMedia() {
    if (widget.mediaCapture.isPicture) return;

    // Get the video file path from captureRequest
    widget.mediaCapture.captureRequest.when(
      single: (single) {
        if (single.file != null && !widget.mediaCapture.isPicture) {
          _videoController = VideoPlayerController.file(
            File(single.file!.path),
          );
          _videoController!.initialize().then((_) {
            setState(() {});
            _videoController!.play();
            _videoController!.setLooping(true);
          });
        }
      },
      multiple: (multiple) {
        // Handle multiple captures if needed
        // For now, just use the first file
        final firstFile = multiple.fileBySensor.values.first;
        if (firstFile != null && !widget.mediaCapture.isPicture) {
          _videoController = VideoPlayerController.file(File(firstFile.path));
          _videoController!.initialize().then((_) {
            setState(() {});
            _videoController!.play();
            _videoController!.setLooping(true);
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: Text(
              'Send',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Media preview
          Positioned.fill(child: _buildMediaPreview(screenSize)),

          // Text overlay (if text is added)
          if (_textController.text.isNotEmpty)
            Positioned(
              left:
                  _textX * screenSize.width -
                  (_textController.text.length * _textSize / 4),
              top: _textY * screenSize.height - _textSize / 2,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _textX = (details.globalPosition.dx / screenSize.width)
                        .clamp(0.0, 1.0);
                    _textY = (details.globalPosition.dy / screenSize.height)
                        .clamp(0.0, 1.0);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _textController.text,
                    style: TextStyle(
                      color: _textColor,
                      fontSize: _textSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // Bottom editing controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildEditingControls(theme),
          ),

          // Text input overlay (when in text mode)
          if (_isTextMode)
            Positioned.fill(child: _buildTextInputOverlay(theme)),
        ],
      ),
    );
  }

  /// Build media preview (photo or video)
  Widget _buildMediaPreview(Size screenSize) {
    if (widget.mediaCapture.isPicture) {
      // Photo preview - get file from captureRequest
      return widget.mediaCapture.captureRequest.when(
        single: (single) {
          return Image.file(
            File(single.file!.path),
            fit: BoxFit.cover,
            width: screenSize.width,
            height: screenSize.height,
          );
        },
        multiple: (multiple) {
          // Handle multiple captures - use first file
          final firstFile = multiple.fileBySensor.values.first;
          return Image.file(
            File(firstFile!.path),
            fit: BoxFit.cover,
            width: screenSize.width,
            height: screenSize.height,
          );
        },
      );
    } else {
      // Video preview
      if (_videoController?.value.isInitialized == true) {
        return AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        );
      } else {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }
    }
  }

  /// Build editing controls at the bottom
  Widget _buildEditingControls(ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Duration slider (for photos only)
          if (widget.mediaCapture.isPicture)
            Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'View for ${_snapDuration}s',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                Slider(
                  value: _snapDuration.toDouble(),
                  min: AppConstants.minSnapDuration.toDouble(),
                  max: AppConstants.maxSnapDuration.toDouble(),
                  divisions:
                      AppConstants.maxSnapDuration -
                      AppConstants.minSnapDuration,
                  onChanged: (value) {
                    setState(() {
                      _snapDuration = value.round();
                    });
                  },
                  activeColor: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
              ],
            ),

          // Editing tool buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildEditButton(
                icon: Icons.text_fields,
                label: 'Text',
                onPressed: () {
                  setState(() {
                    _isTextMode = true;
                  });
                  _textFocusNode.requestFocus();
                },
              ),
              _buildEditButton(
                icon: Icons.palette,
                label: 'Color',
                onPressed: _showColorPicker,
              ),
              _buildEditButton(
                icon: Icons.format_size,
                label: 'Size',
                onPressed: _showSizePicker,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build text input overlay
  Widget _buildTextInputOverlay(ThemeData theme) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
              controller: _textController,
              focusNode: _textFocusNode,
              style: TextStyle(
                color: _textColor,
                fontSize: _textSize,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: 'Add text...',
                hintStyle: TextStyle(color: Colors.white60),
                border: InputBorder.none,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              onSubmitted: (_) {
                setState(() {
                  _isTextMode = false;
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _textController.clear();
                    _isTextMode = false;
                  });
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isTextMode = false;
                  });
                },
                child: Text(
                  'Done',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build edit button widget
  Widget _buildEditButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Show color picker dialog
  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Text Color'),
        content: Wrap(
          spacing: 8,
          children:
              [
                Colors.white,
                Colors.black,
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.yellow,
                Colors.purple,
                Colors.orange,
              ].map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _textColor = color;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _textColor == color ? Colors.blue : Colors.grey,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  /// Show text size picker dialog
  void _showSizePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Text Size'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Sample Text', style: TextStyle(fontSize: _textSize)),
                Slider(
                  value: _textSize,
                  min: 16.0,
                  max: 48.0,
                  onChanged: (value) {
                    setDialogState(() {
                      _textSize = value;
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  /// Handle save/send action
  void _handleSave() {
    // TODO: Implement save/send functionality
    // This would involve:
    // 1. Applying text overlays to the image/video
    // 2. Saving the edited media
    // 3. Navigating to share/send screen or returning to camera

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Send functionality will be implemented in Phase 1.4'),
        duration: Duration(seconds: 2),
      ),
    );

    // For now, just navigate back to camera
    context.pop();
  }
}
