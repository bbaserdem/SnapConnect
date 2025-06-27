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
import '../features/friends/data/friends_notifier.dart';
import '../features/profile/data/public_user_provider.dart';
import '../features/auth/auth.dart';

class SendToBottomSheet extends ConsumerStatefulWidget {
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
  ConsumerState<SendToBottomSheet> createState() => _SendToBottomSheetState();
}

class _SendToBottomSheetState extends ConsumerState<SendToBottomSheet> {
  bool _isPostingStory = false;
  String? _sendingTargetId; // convoId or friendUid being sent

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final conversationsState = ref.watch(conversationsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final storiesRepo = ref.read(storiesRepositoryProvider);
    final currentUid = ref.watch(authUserProvider).value?.uid;

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, controller) {
          // Local state for search query.
          String query = '';
          return StatefulBuilder(
            builder: (context, setStateSB) {
              // Friends data – only accepted friend UIDs.
              final friendIds = ref.watch(acceptedFriendIdsProvider)
                  .where((id) => id != currentUid)
                  .toList();

              // Fetch public profiles for friends.
              final friendProfiles = friendIds
                  .map((uid) => ref.watch(publicUserProvider(uid)))
                  .where((async) => async.hasValue)
                  .map((async) => async.value!)
                  .toList();

              // Apply alphabetical sort.
              friendProfiles.sort((a, b) => a.username.compareTo(b.username));

              // Apply search filter.
              final filteredFriends = query.isEmpty
                  ? friendProfiles
                  : friendProfiles.where((p) =>
                        p.username.toLowerCase().contains(query.toLowerCase()) ||
                        p.displayName.toLowerCase().contains(query.toLowerCase()),
                      ).toList();

              return Padding(
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
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search friends',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (v) => setStateSB(() => query = v.trim()),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      enabled: !_isPostingStory,
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primary,
                        child: _isPostingStory
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.auto_stories, color: Colors.white),
                      ),
                      title: const Text('My Story'),
                      onTap: () async {
                        if (_isPostingStory) return;
                        setState(() => _isPostingStory = true);

                        // Show blocking dialog to indicate upload
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );

                        try {
                          await storiesRepo.addStory(
                            file: File(widget.mediaPath),
                            type: widget.isPicture ? StoryMediaType.photo : StoryMediaType.video,
                            duration: widget.isPicture ? widget.duration : null,
                          );

                          // Dismiss loading dialog first
                          if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

                          // Close the sheet and the editor before showing success.
                          if (context.mounted) {
                            Navigator.of(context).pop(); // close sheet
                            Navigator.of(context).pop(); // close editor
                          }
                        } catch (e) {
                          if (context.mounted) {
                            Navigator.of(context, rootNavigator: true).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to add story: $e')),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isPostingStory = false);
                        }
                      },
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView(
                        controller: controller,
                        children: [
                          // Existing conversations first.
                          ...conversationsState.conversations.where((conv) {
                            // Skip self-conversation and duplicates.
                            if (currentUid == null) return true;
                            final others = conv.participantIds.where((id) => id != currentUid);
                            return others.isNotEmpty;
                          }).map((conv) {
                            final displayName = conv.getDisplayName(currentUid ?? '');
                            final messageType = widget.keepInChat
                                ? (widget.isPicture ? MessageType.image : MessageType.video)
                                : (widget.isPicture ? MessageType.snap : MessageType.video);
                            final sender = ref.read(sendMediaMessageProvider(conv.id));
                            return ListTile(
                              leading: CircleAvatar(child: Text(displayName.isNotEmpty ? displayName[0] : '?')),
                              title: Text(displayName),
                              subtitle: Text(conv.isGroup ? 'Group chat' : 'Direct'),
                              enabled: _sendingTargetId == null,
                              trailing: _sendingTargetId == conv.id
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                  : null,
                              onTap: () async {
                                if (_sendingTargetId != null) return;
                                setState(() => _sendingTargetId = conv.id);
                                final messenger = ScaffoldMessenger.of(context);
                                try {
                                  await sender(
                                    mediaPath: widget.mediaPath,
                                    type: messageType,
                                    duration: widget.keepInChat ? null : widget.duration,
                                  );
                                  if (context.mounted) {
                                    Navigator.of(context).pop(); // close sheet
                                    Navigator.of(context).pop(); // close editor
                                  }
                                  messenger.showSnackBar(
                                    SnackBar(content: Text('Sent to $displayName')),
                                  );
                                } catch (e) {
                                  messenger.showSnackBar(
                                    SnackBar(content: Text('Failed to send: $e')),
                                  );
                                } finally {
                                  if (mounted) setState(() => _sendingTargetId = null);
                                }
                              },
                            );
                          }),
                          if (filteredFriends.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('Friends', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            ...filteredFriends.map((user) {
                              return ListTile(
                                leading: CircleAvatar(child: Text(user.username.isNotEmpty ? user.username[0].toUpperCase() : '?')),
                                title: Text(user.username),
                                subtitle: user.displayName.isNotEmpty ? Text(user.displayName) : null,
                                enabled: _sendingTargetId == null,
                                trailing: _sendingTargetId == user.uid
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                    : null,
                                onTap: () async {
                                  if (_sendingTargetId != null) return;
                                  setState(() => _sendingTargetId = user.uid);
                                  final messenger = ScaffoldMessenger.of(context);
                                  try {
                                    final conv = await ref.read(conversationsProvider.notifier).createOrGetDirectConversation(
                                          otherUserId: user.uid,
                                          otherUsername: user.username,
                                        );
                                    if (conv == null) {
                                      messenger.showSnackBar(const SnackBar(content: Text('Failed to create conversation')));
                                      return;
                                    }
                                    final messageType = widget.keepInChat
                                        ? (widget.isPicture ? MessageType.image : MessageType.video)
                                        : (widget.isPicture ? MessageType.snap : MessageType.video);
                                    await ref.read(sendMediaMessageProvider(conv.id))(
                                      mediaPath: widget.mediaPath,
                                      type: messageType,
                                      duration: widget.keepInChat ? null : widget.duration,
                                    );
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    }
                                    messenger.showSnackBar(SnackBar(content: Text('Sent to ${user.username}')));
                                  } catch (e) {
                                    messenger.showSnackBar(SnackBar(content: Text('Failed: $e')));
                                  } finally {
                                    if (mounted) setState(() => _sendingTargetId = null);
                                  }
                                },
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
} 