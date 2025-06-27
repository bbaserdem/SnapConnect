/// Messages screen for viewing and managing conversations.
/// 
/// This screen displays a list of recent conversations with real-time updates
/// and allows users to access their direct messages and group chats.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/conversations_notifier.dart';
import '../../auth/auth.dart';
import 'new_message_dialog.dart';
import 'messages_widgets.dart';

/// Main messages screen widget
class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final conversationsState = ref.watch(conversationsProvider);
    final authUser = ref.watch(authUserProvider);

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
              _showNewMessageDialog(context, ref);
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
              onChanged: (value) {
                // TODO: Implement search functionality
              },
            ),
          ),
          
          ConnectionStatusBanner(state: conversationsState),
          
          // Conversations list
          Expanded(
            child: ConversationsListView(
              state: conversationsState,
              currentUser: authUser.valueOrNull,
            ),
          ),
        ],
      ),
    );
  }

  /// Shows the new message dialog
  void _showNewMessageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => const NewMessageDialog(),
    );
  }
} 