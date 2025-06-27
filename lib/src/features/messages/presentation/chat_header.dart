/// Chat header widget used inside AppBar of ChatScreen.
/// Displays avatar, display name, handle or participant count.

import 'package:flutter/material.dart';
import '../data/conversation_model.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({
    super.key,
    required this.conversation,
    required this.currentUserId,
  });

  final ConversationModel conversation;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final displayName = conversation.getDisplayName(currentUserId);

    String? handle;
    if (!conversation.isGroup) {
      final otherId = conversation.participantIds.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );
      handle = conversation.participantUsernames[otherId];
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: conversation.isGroup ? cs.tertiary : cs.primary,
          child: conversation.isGroup
              ? Icon(Icons.group, color: cs.onTertiary, size: 20)
              : Text(_initials(displayName), style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(displayName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              if (handle != null && handle.isNotEmpty)
                Text('@$handle', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
              if (conversation.isGroup)
                Text('${conversation.participantIds.length} participants', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.7))),
            ],
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts.isNotEmpty ? parts[0].substring(0, 1).toUpperCase() : 'U';
  }
} 