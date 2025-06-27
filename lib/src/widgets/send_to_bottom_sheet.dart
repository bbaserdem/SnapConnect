/// Bottom sheet to select a conversation and send a snap/video.
///
/// Displays list of existing conversations via [conversationsProvider].
/// Upon selection, calls the appropriate send function and pops all the way
/// back to the camera screen.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/messages/data/conversations_notifier.dart';
import '../features/messages/data/message_model.dart';
import '../features/messages/data/messages_notifier.dart';
import '../features/stories/data/stories_notifier.dart';
import '../features/stories/data/story_model.dart';

class SendToBottomSheet extends ConsumerWidget {
  const SendToBottomSheet({
    required this.mediaPath,
    required this.isPicture,
    required this.duration,
    required this.keepInChat,
    super.key,
  });

  final String mediaPath;
  final bool isPicture; // false = video
  final int? duration; // seconds
  final bool keepInChat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsState = ref.watch(conversationsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final storiesRepo = ref.read(storiesRepositoryProvider);

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, controller) {
          return StatefulBuilder(
            builder: (context, setStateSB) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('Send To', style: Theme.of(context).textTheme.titleLarge),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.primary,
                      child: const Icon(Icons.auto_stories, color: Colors.white),
                    ),
                    title: const Text('My Story'),
                    onTap: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Posting to your story...')),
                      );

                      try {
                        await storiesRepo.addStory(
                          file: File(mediaPath),
                          type: isPicture ? StoryMediaType.photo : StoryMediaType.video,
                          duration: isPicture ? duration : null,
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop(); // close sheet
                          Navigator.of(context).pop(); // close editor
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to My Story')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add story: $e')),
                        );
                      }
                    },
                  ),
                  const Divider(),
                  Expanded(
                    child: conversationsState.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            controller: controller,
                            itemCount: conversationsState.conversations.length,
                            itemBuilder: (context, index) {
                              final conv = conversationsState.conversations[index];
                              final displayName = conv.getDisplayName('');
                              final messageType = keepInChat
                                  ? (isPicture ? MessageType.image : MessageType.video)
                                  : (isPicture ? MessageType.snap : MessageType.video);
                              final sender = ref.read(sendMediaMessageProvider(conv.id));
                              return ListTile(
                                leading: CircleAvatar(child: Text(displayName.isNotEmpty ? displayName[0] : '?')),
                                title: Text(displayName),
                                subtitle: Text(conv.isGroup ? 'Group chat' : 'Direct'),
                                onTap: () async {
                                  try {
                                    await sender(
                                      mediaPath: mediaPath,
                                      type: messageType,
                                      duration: keepInChat ? null : duration,
                                    );
                                    if (context.mounted) {
                                      Navigator.of(context).pop(); // close sheet
                                      Navigator.of(context).pop(); // close editor
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Sent to $displayName')),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed to send: $e')),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 