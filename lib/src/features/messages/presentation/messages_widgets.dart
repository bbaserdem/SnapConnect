/// Helper widgets used by `messages_screen.dart` to keep the main screen small.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/conversations_notifier.dart';
import '../data/conversation_model.dart';
import 'conversation_tile.dart';
import 'chat_screen.dart';

// ---------------------------------------------------------------------------
class ConnectionStatusBanner extends StatelessWidget {
  const ConnectionStatusBanner({super.key, required this.state});

  final ConversationsState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.conversations.isEmpty) return const SizedBox.shrink();

    if (state.isFromCache) {
      return _coloredBanner(
        context,
        icon: Icons.cloud_off,
        color: Colors.orange,
        message: 'Offline - Showing cached conversations',
        extra: 'Conversations loaded: ${state.conversations.length}',
      );
    }

    if (state.error != null) {
      return _coloredBanner(
        context,
        icon: Icons.error_outline,
        color: Colors.red,
        message: state.error!,
      );
    }

    return _coloredBanner(
      context,
      icon: Icons.cloud_done,
      color: Colors.green,
      message: 'Connected - ${state.conversations.length} conversations',
    );
  }

  Widget _coloredBanner(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String message,
    String? extra,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: color.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                if (extra != null)
                  Text(extra, style: TextStyle(color: color, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class ConversationsListView extends ConsumerWidget {
  const ConversationsListView({
    super.key,
    required this.state,
    required this.currentUser,
  });

  final ConversationsState state;
  final User? currentUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading && state.conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.conversations.isEmpty) {
      return const _EmptyConversations();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(conversationsProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.conversations.length,
        itemBuilder: (context, index) {
          final conversation = state.conversations[index];
          return ConversationTile(
            conversation: conversation,
            currentUserId: currentUser?.uid ?? '',
            onTap: () => _openConversation(context, conversation),
          );
        },
      ),
    );
  }

  void _openConversation(BuildContext context, ConversationModel conv) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(conversation: conv)),
    );
  }
}

// ---------------------------------------------------------------------------
class _EmptyConversations extends StatelessWidget {
  const _EmptyConversations();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: EdgeInsets.only(top: constraints.maxHeight * 0.2, left: 16, right: 16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_bubble_outline, size: 64, color: colorScheme.onSurface.withValues(alpha: 0.6)),
              const SizedBox(height: 16),
              Text('No conversations yet', style: theme.textTheme.titleLarge?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6))),
              const SizedBox(height: 8),
              Text('Start a conversation with your friends!', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6))),
            ],
          ),
        ),
      ),
    );
  }
} 