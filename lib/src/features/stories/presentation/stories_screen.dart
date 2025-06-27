/// Stories screen for viewing and managing user stories.
/// 
/// This screen displays stories from friends and allows users to
/// view story content in a full-screen interface.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/stories_notifier.dart';
import '../data/story_model.dart';

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
                    'My Story',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMyStoryCard(context),
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
                  _buildStoriesGrid(context, storiesState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the "My Story" card
  Widget _buildMyStoryCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add to Story functionality coming in Phase 1.5'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: colorScheme.primary,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add to Your Story',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Share a moment with your friends',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the grid of friends' stories
  Widget _buildStoriesGrid(BuildContext context, StoriesState storiesState) {
    if (storiesState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (storiesState.error != null) {
      return Center(
        child: Text(
          storiesState.error!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (storiesState.stories.isEmpty) {
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
      itemCount: storiesState.stories.length,
      itemBuilder: (context, index) {
        final storyDoc = storiesState.stories[index];
        final lastMedia = storyDoc.media.isNotEmpty ? storyDoc.media.last : null;
        final postedAt = lastMedia?.postedAt ?? storyDoc.updatedAt;
        final timeDiff = DateTime.now().difference(postedAt);
        final timestamp = _formatTimestamp(timeDiff);

        return _buildStoryCard(
          context,
          name: storyDoc.userId,
          username: storyDoc.userId,
          timestamp: timestamp,
          hasNewStory: true,
          storyDoc: storyDoc,
        );
      },
    );
  }

  /// Builds an individual story card
  Widget _buildStoryCard(
    BuildContext context, {
    required String name,
    required String username,
    required String timestamp,
    required bool hasNewStory,
    StoryDocument? storyDoc,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: InkWell(
        onTap: () => _openStory(context, name),
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Story preview background
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
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
                            name[0],
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
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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

  /// Opens a story viewer (placeholder functionality)
  void _openStory(BuildContext context, String userName) {
    context.push('/story-viewer/$userName');
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
} 