/// Messages screen for viewing and managing conversations.
/// 
/// This screen displays a list of recent conversations and allows
/// users to access their direct messages and group chats.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Main messages screen widget
class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
              _showNewMessageDialog(context);
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 8, // Placeholder count
              itemBuilder: (context, index) {
                return _buildConversationTile(
                  name: index == 0 ? 'Body Mod Squad' : 'User $index',
                  lastMessage: _getLastMessage(index),
                  timestamp: _getTimestamp(index),
                  avatarText: index == 0 ? 'BMS' : 'U$index',
                  isGroup: index == 0,
                  hasUnread: index % 3 == 0,
                  unreadCount: index % 3 == 0 ? index + 1 : 0,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a conversation list tile
  Widget _buildConversationTile({
    required String name,
    required String lastMessage,
    required String timestamp,
    required String avatarText,
    required bool isGroup,
    required bool hasUnread,
    required int unreadCount,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  backgroundColor: isGroup 
                      ? colorScheme.tertiary 
                      : colorScheme.primary,
                  child: isGroup
                      ? Icon(
                          Icons.group,
                          color: colorScheme.onTertiary,
                        )
                      : Text(
                          avatarText,
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                if (hasUnread && unreadCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              name,
              style: TextStyle(
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              lastMessage,
              style: TextStyle(
                color: hasUnread 
                    ? colorScheme.onSurface 
                    : colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timestamp,
                  style: TextStyle(
                    color: hasUnread 
                        ? colorScheme.primary 
                        : colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (hasUnread)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            onTap: () {
              _openConversation(context, name, isGroup);
            },
          ),
        );
      },
    );
  }

  /// Gets placeholder last message for a conversation
  String _getLastMessage(int index) {
    final messages = [
      '📸 Check out my new tattoo!',
      'Hey! How\'s the healing going?',
      'That piercing looks amazing!',
      'Thanks for the aftercare tips 💯',
      'Group: Anyone know a good artist in NYC?',
      'Thinking about getting another one...',
      'Your modification journey is inspiring!',
      '🔥 Love the new look!',
    ];
    return messages[index % messages.length];
  }

  /// Gets placeholder timestamp for a conversation
  String _getTimestamp(int index) {
    final timestamps = [
      'now',
      '5m',
      '1h',
      '2h',
      '1d',
      '2d',
      '1w',
      '2w',
    ];
    return timestamps[index % timestamps.length];
  }

  /// Shows the new message dialog
  void _showNewMessageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Message'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Search for friends to message',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Messaging will be implemented in Phase 1.4'),
                ),
              );
            },
            child: const Text('Start Chat'),
          ),
        ],
      ),
    );
  }

  /// Opens a conversation (placeholder functionality)
  void _openConversation(BuildContext context, String name, bool isGroup) {
    final chatType = isGroup ? 'group chat' : 'conversation';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $chatType with $name (Feature coming in Phase 1.4)'),
      ),
    );
  }
} 