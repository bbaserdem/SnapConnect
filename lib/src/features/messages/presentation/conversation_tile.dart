/// Conversation tile widget used in the messages list.
///
/// Moved out of `messages_screen.dart` to keep files under the 500-line
/// guideline and enable reuse in other screens.
///
/// The widget displays avatar/initials, unread badge, last-message preview
/// and timestamp. It remains functionally identical to the previous in-file
/// implementation.

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../data/conversation_model.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
    super.key,
  });

  /// Conversation to display.
  final ConversationModel conversation;

  /// UID of the current logged-in user (used to compute display name).
  final String currentUserId;

  /// Callback invoked when the tile is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final displayName = conversation.getDisplayName(currentUserId);
    final unreadCount = conversation.getUnreadCount(currentUserId);
    final hasUnread = unreadCount > 0;
    final lastMessageTime = conversation.lastMessageTimestamp;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _buildAvatar(colorScheme, displayName, hasUnread, unreadCount),
        title: Text(
          displayName,
          style: TextStyle(
            fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          conversation.lastMessageContent ?? 'No messages yet',
          style: TextStyle(
            color: hasUnread
                ? colorScheme.onSurface
                : colorScheme.onSurface.withOpacity(0.6),
            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: _buildTrailing(colorScheme, hasUnread, unreadCount, lastMessageTime),
        onTap: onTap,
      ),
    );
  }

  /// Builds the avatar with optional unread badge overlay.
  Widget _buildAvatar(ColorScheme colorScheme, String displayName, bool hasUnread, int unreadCount) {
    return Stack(
      children: [
        CircleAvatar(
          backgroundColor:
              conversation.isGroup ? colorScheme.tertiary : colorScheme.primary,
          child: conversation.isGroup
              ? Text(
                  _getInitials(conversation.groupName ?? 'GC'),
                  style: TextStyle(
                    color: colorScheme.onTertiary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Text(
                  _getInitials(displayName),
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        if (hasUnread)
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
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
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
    );
  }

  /// Builds the trailing timestamp + unread dot.
  Widget _buildTrailing(ColorScheme colorScheme, bool hasUnread, int unreadCount, DateTime? lastMessageTime) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (lastMessageTime != null)
          Text(
            timeago.format(lastMessageTime, locale: 'en_short'),
            style: TextStyle(
              color: hasUnread ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
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
    );
  }

  /// Returns up to two initials from the display name.
  String _getInitials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    if (words.isNotEmpty) {
      final first = words[0];
      return first.substring(0, first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'U';
  }
} 