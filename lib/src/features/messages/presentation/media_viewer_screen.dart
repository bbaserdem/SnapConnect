/// Full-screen viewer for images and snap photos.
/// If [isSnap] is true and [duration] is provided, the screen auto-closes
/// after that many seconds (simulating disappearing snap).

import 'dart:async';

import 'package:flutter/material.dart';

class MediaViewerScreen extends StatefulWidget {
  const MediaViewerScreen({
    required this.mediaUrl,
    this.isSnap = false,
    this.duration,
    super.key,
  });

  final String mediaUrl;
  final bool isSnap;
  final int? duration; // seconds

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.isSnap && widget.duration != null) {
      _timer = Timer(Duration(seconds: widget.duration!), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: Image.network(widget.mediaUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (ctx, child, progress) {
                if (progress == null) return child;
                return const CircularProgressIndicator(color: Colors.white);
              }),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
} 