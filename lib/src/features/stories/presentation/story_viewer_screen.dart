/// Full-screen viewer for playing a user's story sequence.
///
/// The viewer listens to the real-time story document stream so that new
/// snaps are pulled in without requiring the user to restart the viewer.
/// For images we auto-advance after a set duration (default 5 s or the
/// provided `duration` field). Videos are played fully using the
/// `video_player` package.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:go_router/go_router.dart';

import '../data/stories_notifier.dart';
import '../data/story_model.dart';

class StoryViewerScreen extends ConsumerStatefulWidget {
  const StoryViewerScreen({required this.userId, super.key});

  final String userId;

  @override
  ConsumerState<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen> {
  int _currentIndex = 0;
  Timer? _timer;
  VideoPlayerController? _videoController;

  @override
  void dispose() {
    _timer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storiesState = ref.watch(storiesProvider);
    final storyDoc = storiesState.stories.firstWhere(
      (s) => s.userId == widget.userId,
      orElse: () => StoryDocument(userId: '', media: const [], updatedAt: DateTime.now()),
    );

    if (storiesState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (storyDoc.media.isEmpty) {
      return const Scaffold(body: Center(child: Text('No story')));
    }

    final media = storyDoc.media[_currentIndex];

    _setupAutoAdvance(media);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          // Tapping right half advances, left half goes back.
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx > screenWidth / 2) {
            _next(storyDoc);
          } else {
            _prev();
          }
        },
        child: Stack(
          children: [
            Positioned.fill(child: _buildMedia(media)),
            _buildProgressBar(storyDoc.media.length),
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int segments) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 8,
      right: 8,
      child: Row(
        children: List.generate(segments, (i) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 2,
              color: i <= _currentIndex ? Colors.white : Colors.white54,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMedia(StoryMedia media) {
    if (media.type == StoryMediaType.video) {
      if (_videoController == null || !_videoController!.value.isInitialized) {
        _videoController?.dispose();
        _videoController = VideoPlayerController.network(media.url)
          ..initialize().then((_) {
            setState(() {});
            _videoController!.play();
          });
        return const Center(child: CircularProgressIndicator());
      }
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _videoController!.value.size.width,
          height: _videoController!.value.size.height,
          child: VideoPlayer(_videoController!),
        ),
      );
    } else {
      return Image.network(media.url, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    }
  }

  void _setupAutoAdvance(StoryMedia media) {
    _timer?.cancel();

    // For videos we advance once playback finishes; for photos use duration.
    if (media.type == StoryMediaType.video) {
      _videoController?.addListener(() {
        if (_videoController!.value.position >= _videoController!.value.duration) {
          _nextFromMedia(media);
        }
      });
    } else {
      final seconds = media.duration ?? 5;
      _timer = Timer(Duration(seconds: seconds), () => _nextFromMedia(media));
    }
  }

  void _nextFromMedia(StoryMedia media) {
    final storiesState = ref.read(storiesProvider);
    final storyDoc = storiesState.stories.firstWhere((s) => s.userId == widget.userId);
    if (_currentIndex < storyDoc.media.length - 1) {
      setState(() => _currentIndex++);
    } else {
      context.pop();
    }
  }

  void _next(StoryDocument doc) {
    if (_currentIndex < doc.media.length - 1) {
      setState(() => _currentIndex++);
    } else {
      context.pop();
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }
} 