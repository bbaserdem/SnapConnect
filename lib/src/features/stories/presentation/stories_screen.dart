/// Stories screen for viewing and managing user stories.
/// 
/// This screen displays stories from friends and allows users to
/// view story content in a full-screen interface.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/stories_notifier.dart';
import '../data/story_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../auth/auth.dart';

/// Family provider to fetch a user\'s username by UID.
final _usernameProvider = FutureProvider.family<String, String>((ref, uid) async {
  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  final data = doc.data();
  return data?['username'] as String? ?? uid;
});

/// Main stories screen widget
class StoriesScreen extends ConsumerWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final storiesState = ref.watch(storiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stories'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // My Story section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Stories',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildMyStoriesRow(context, storiesState),
                ],
              ),
            ),
            
            const Divider(),
            
            // Friends' Stories section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Friends\' Stories',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStoriesGrid(context, ref, storiesState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds horizontal list of current user's story media cards.
  Widget _buildMyStoriesRow(BuildContext context, StoriesState state) {
    // find current user's stories
    return Consumer(builder: (context, ref, _) {
      final user = ref.watch(authUserProvider).value;
      if (user == null) return const SizedBox.shrink();
      final myDoc = state.stories.firstWhere((s) => s.userId == user.uid, orElse: () => StoryDocument(userId: '', media: const [], updatedAt: DateTime(0)));
      if (myDoc.userId.isEmpty || myDoc.media.isEmpty) {
        return const Text('No stories yet');
      }

      return SizedBox(
        height: 180,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: myDoc.media.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final media = myDoc.media[index];
            return SizedBox(
              width: 120,
              child: _buildStoryCard(
                context,
                uid: user.uid,
                timestamp: _formatTimestamp(DateTime.now().difference(media.postedAt)),
                hasNewStory: false,
                storyDoc: StoryDocument(userId: user.uid, media: [media], updatedAt: media.postedAt),
                storyIndex: index,
              ),
            );
          },
        ),
      );
    });
  }

  /// Builds the grid of friends' stories
  Widget _buildStoriesGrid(BuildContext context, WidgetRef ref, StoriesState storiesState) {
    final currentUid = ref.read(authUserProvider).value?.uid;
    final friendStories = currentUid == null
        ? storiesState.stories
        : storiesState.stories.where((s) => s.userId != currentUid).toList();

    if (friendStories.isEmpty) {
      return const Center(child: Text('No stories yet'));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: friendStories.length,
      itemBuilder: (context, index) {
        final storyDoc = friendStories[index];
        final lastMedia = storyDoc.media.isNotEmpty ? storyDoc.media.last : null;
        final postedAt = lastMedia?.postedAt ?? storyDoc.updatedAt;
        final timeDiff = DateTime.now().difference(postedAt);
        final timestamp = _formatTimestamp(timeDiff);

        return _buildStoryCard(
          context,
          uid: storyDoc.userId,
          timestamp: timestamp,
          hasNewStory: true,
          storyDoc: storyDoc,
          storyIndex: 0,
        );
      },
    );
  }

  /// Builds an individual story card
  Widget _buildStoryCard(
    BuildContext context, {
    required String uid,
    required String timestamp,
    required bool hasNewStory,
    required int storyIndex,
    StoryDocument? storyDoc,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final previewMedia = storyDoc?.media.isNotEmpty == true ? storyDoc!.media.last : null;

    return Card(
      child: InkWell(
        onTap: () => _openStory(context, uid, storyIndex),
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Story preview background or placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: previewMedia == null
                  ? _placeholderBackground(colorScheme)
                  : previewMedia.type == StoryMediaType.photo
                      ? Image.network(
                          previewMedia.url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) => _placeholderBackground(colorScheme),
                        )
                      : _VideoStoryThumbnail(
                          videoUrl: previewMedia.url,
                          placeholder: _placeholderBackground(colorScheme),
                        ),
            ),
            
            // Story preview overlay
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            
            // User info
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: hasNewStory ? colorScheme.primary : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            uid[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Consumer(
                              builder: (context, ref, _) {
                                final asyncUsername = ref.watch(_usernameProvider(uid));
                                final display = asyncUsername.when(
                                  data: (u) => u,
                                  loading: () => '...',
                                  error: (_, __) => uid.substring(0,6),
                                );
                                return Text(
                                  display,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                            Text(
                              timestamp,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // New story indicator
            if (hasNewStory)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Opens a story viewer with the specified story index
  void _openStory(BuildContext context, String userId, int storyIndex) {
    context.push('/story-viewer/$userId?index=$storyIndex');
  }

  String _formatTimestamp(Duration diff) {
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else {
      return '${diff.inDays}d';
    }
  }

  Widget _placeholderBackground(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primary.withValues(alpha: 0.7),
            colorScheme.secondary.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.camera_alt,
          size: 48,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

/// Widget that generates and caches a thumbnail for a remote video URL.
class _VideoStoryThumbnail extends StatefulWidget {
  const _VideoStoryThumbnail({required this.videoUrl, required this.placeholder});

  final String videoUrl;
  final Widget placeholder;

  @override
  State<_VideoStoryThumbnail> createState() => _VideoStoryThumbnailState();
}

class _VideoStoryThumbnailState extends State<_VideoStoryThumbnail> {
  Uint8List? _bytes;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    try {
      final bytes = await VideoThumbnail.thumbnailData(
        video: widget.videoUrl,
        imageFormat: ImageFormat.PNG,
        maxWidth: 400,
        quality: 75,
      );
      if (mounted) {
        setState(() => _bytes = bytes);
      }
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes != null) {
      return Image.memory(
        _bytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (_error) return widget.placeholder;
    return Center(child: widget.placeholder);
  }
} 