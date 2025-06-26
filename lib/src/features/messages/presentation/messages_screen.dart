// Messages screen for viewing and managing conversations.
//
// This screen displays a list of recent conversations and allows
// users to access their direct messages and group chats.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/auth.dart';
import '../data/providers/messages_providers.dart';
import '../data/models/models.dart';

/// Main messages screen widget
class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authUser = ref.watch(authUserProvider).value;

    if (authUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment),
            onPressed: () {
              _showNewMessageDialog(context, ref, authUser.uid);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search conversations',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: colorScheme.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Conversations list
          Expanded(
            child: _buildConversationsList(context, ref, authUser.uid),
          ),
        ],
      ),
    );
  }

  /// Builds the conversations list using real Firestore data
  Widget _buildConversationsList(BuildContext context, WidgetRef ref, String userId) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return conversationsAsync.when(
      data: (conversations) {
        if (conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No conversations yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start a conversation with friends',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => _showNewMessageDialog(context, ref, userId),
                  icon: const Icon(Icons.add),
                  label: const Text('Start Chatting'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conversation = conversations[index];
            return _buildConversationTile(
              context: context,
              ref: ref,
              conversation: conversation,
              currentUserId: userId,
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load conversations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.refresh(conversationsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a conversation list tile with real data
  Widget _buildConversationTile({
    required BuildContext context,
    required WidgetRef ref,
    required ConversationModel conversation,
    required String currentUserId,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final displayName = conversation.getDisplayName(currentUserId);
    final lastMessageText = conversation.lastMessageContent ?? 'No messages yet';
    final timeAgo = conversation.lastMessageTime?.let((time) => _getTimeAgo(time)) ?? '';
    final isGroup = conversation.type == ConversationType.group;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isGroup
              ? colorScheme.tertiary
              : colorScheme.primary,
          child: isGroup
              ? Icon(Icons.group, color: colorScheme.onTertiary)
              : Text(
                  _getInitials(displayName),
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        title: Text(
          displayName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          lastMessageText,
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: timeAgo.isNotEmpty
            ? Text(
                timeAgo,
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              )
            : null,
        onTap: () {
          _openConversation(context, conversation);
        },
      ),
    );
  }

  /// Shows the new message dialog with user search
  void _showNewMessageDialog(BuildContext context, WidgetRef ref, String currentUserId) {
    showDialog(
      context: context,
      builder: (context) => _NewMessageDialog(currentUserId: currentUserId),
    );
  }

  /// Opens a conversation screen
  void _openConversation(BuildContext context, ConversationModel conversation) {
    // TODO: Navigate to chat screen when implemented
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Opening chat with ${conversation.getDisplayName('')}...',
        ),
      ),
    );
  }

  /// Gets initials from a name
  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final words = name.split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  /// Gets time ago string from timestamp
  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${difference.inDays ~/ 7}w';
    }
  }
}

/// Dialog for creating new messages with user search
class _NewMessageDialog extends ConsumerStatefulWidget {
  final String currentUserId;

  const _NewMessageDialog({required this.currentUserId});

  @override
  ConsumerState<_NewMessageDialog> createState() => _NewMessageDialogState();
}

class _NewMessageDialogState extends ConsumerState<_NewMessageDialog> {
  final _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userSearchState = ref.watch(userSearchProvider);
    final conversationCreationState = ref.watch(conversationCreationProvider);

    return AlertDialog(
      title: const Text('New Message'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search for users by username',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                ref.read(userSearchProvider.notifier)
                    .searchUsers(value, widget.currentUserId);
              },
            ),
            const SizedBox(height: 16),
            if (userSearchState.isLoading)
              const CircularProgressIndicator()
            else if (userSearchState.error != null)
              Text(
                userSearchState.error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              )
            else if (userSearchState.users.isNotEmpty)
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: userSearchState.users.length,
                  itemBuilder: (context, index) {
                    final user = userSearchState.users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          user.username.substring(0, 1).toUpperCase(),
                        ),
                      ),
                      title: Text(user.username),
                      subtitle: user.bio.isNotEmpty ? Text(user.bio) : null,
                      onTap: () => _startConversation(user),
                      enabled: !conversationCreationState.isCreating,
                    );
                  },
                ),
              )
            else if (userSearchState.query.isNotEmpty)
              const Text('No users found'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: conversationCreationState.isCreating 
              ? null 
              : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  /// Start a conversation with a user
  Future<void> _startConversation(UserModel user) async {
    final conversationNotifier = ref.read(conversationCreationProvider.notifier);
    
    // Get current user data
    final authUser = ref.read(authUserProvider).value;
    if (authUser == null) return;

    final currentUserDoc = await ref
        .read(authRepositoryProvider)
        .getUserDocument(authUser.uid);
    
    if (currentUserDoc == null || !currentUserDoc.exists) return;
    
    final userData = currentUserDoc.data();
    if (userData == null) return;
    
    final currentUsername = userData['username'] as String;

    final conversationId = await conversationNotifier.createDirectConversation(
      currentUserId: authUser.uid,
      otherUserId: user.id,
      currentUsername: currentUsername,
      otherUsername: user.username,
    );

    if (conversationId != null && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Started conversation with ${user.username}'),
        ),
      );
    }
  }
}

/// Extension to add null-aware let function
extension NullableExtension<T> on T? {
  R? let<R>(R Function(T) transform) {
    if (this != null) {
      return transform(this!);
    }
    return null;
  }
}
