/// Snap editing screen for adding text overlays and setting view duration.
/// 
/// This screen allows users to edit their captured snaps by adding text,
/// setting view duration, and choosing how to share their content.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:video_player/video_player.dart';

import '../../../widgets/send_to_bottom_sheet.dart';
import 'snap_editing_controls.dart';

/// Snap edit screen widget
class SnapEditScreen extends ConsumerStatefulWidget {
  const SnapEditScreen({
    required this.mediaCapture,
    super.key,
  });

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
  bool _keepInChat = false;
  String? _mediaPath;

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
    // Save file path regardless of media type
    widget.mediaCapture.captureRequest.when(
      single: (single) {
        if (single.file != null) {
          _mediaPath = single.file!.path;
          if (!widget.mediaCapture.isPicture) {
            _videoController = VideoPlayerController.file(File(single.file!.path));
            _videoController!.initialize().then((_) {
              setState(() {});
              _videoController!.play();
              _videoController!.setLooping(true);
            });
          }
        }
      },
      multiple: (multiple) {
        final firstFile = multiple.fileBySensor.values.first;
        if (firstFile != null) {
          _mediaPath = firstFile.path;
          if (!widget.mediaCapture.isPicture) {
            _videoController = VideoPlayerController.file(File(firstFile.path));
            _videoController!.initialize().then((_) {
              setState(() {});
              _videoController!.play();
              _videoController!.setLooping(true);
            });
          }
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
          Positioned.fill(
            child: _buildMediaPreview(screenSize),
          ),

          // Text overlay (if text is added)
          if (_textController.text.isNotEmpty)
            Positioned(
              left: _textX * screenSize.width - (_textController.text.length * _textSize / 4),
              top: _textY * screenSize.height - _textSize / 2,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _textX = (details.globalPosition.dx / screenSize.width).clamp(0.0, 1.0);
                    _textY = (details.globalPosition.dy / screenSize.height).clamp(0.0, 1.0);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            child: SnapEditingControls(
              isPicture: widget.mediaCapture.isPicture,
              snapDuration: _snapDuration,
              onSnapDurationChange: (v) => setState(() => _snapDuration = v),
              keepInChat: _keepInChat,
              onToggleKeepInChat: () => setState(() => _keepInChat = !_keepInChat),
              onEnterTextMode: () {
                setState(() => _isTextMode = true);
                _textFocusNode.requestFocus();
              },
              onShowColorPicker: _showColorPicker,
              onShowSizePicker: _showSizePicker,
            ),
          ),

          // Text input overlay (when in text mode)
          if (_isTextMode)
            Positioned.fill(
              child: _buildTextInputOverlay(theme),
            ),
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
                child: const Text('Cancel', style: TextStyle(color: Colors.white)),
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

  /// Show color picker dialog
  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Text Color'),
        content: Wrap(
          spacing: 8,
          children: [
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
                Text(
                  'Sample Text',
                  style: TextStyle(fontSize: _textSize),
                ),
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
    if (_mediaPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to locate captured media.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SendToBottomSheet(
        mediaPath: _mediaPath!,
        isPicture: widget.mediaCapture.isPicture,
        duration: _keepInChat ? null : _snapDuration,
        keepInChat: _keepInChat,
      ),
    );
  }
} 