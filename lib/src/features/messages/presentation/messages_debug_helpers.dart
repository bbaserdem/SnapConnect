/// Collection of debug / demo helpers only used during development.
/// These methods are **not** included in production builds.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../data/conversation_model.dart';
import 'chat_screen.dart';

class MessagesDebug {
  const MessagesDebug._();

  /* Creates an offline demo conversation and opens it */
  static void createOfflineTestConversation(
    BuildContext context,
    WidgetRef ref,
  ) {
    if (!kDebugMode) return;
    final fakeConversation = ConversationModel(
      id: 'offline_test_conversation',
      participantIds: ['current_user', 'test_user_123'],
      participantUsernames: {
        'current_user': 'You',
        'test_user_123': 'Test Buddy',
      },
      isGroup: false,
      lastMessageContent: 'This is an offline test conversation',
      lastMessageTimestamp: DateTime.now(),
      lastViewedTimestamps: {
        'current_user': DateTime.now(),
        'test_user_123': DateTime.now(),
      },
      unreadCounts: {
        'current_user': 0,
        'test_user_123': 1,
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(conversation: fakeConversation)),
    );

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Offline demo conversation created!'),
    ));
  }

  /* ---------------------------------------------------------------------- */
  static void showDemoDialog(BuildContext context, ConversationModel conv) {
    if (!kDebugMode) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _DemoHeader(conversation: conv),
              const Divider(),
              Expanded(child: _DemoMessages()),
              _DemoInput(onSend: (msg) => _sendDemoMessage(context, msg)),
            ],
          ),
        ),
      ),
    );
  }

  static void _sendDemoMessage(BuildContext context, String text) {
    if (text.trim().isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Demo: "$text" sent')),
    );
  }

  /* Network error helper banner */
  static void showNetworkErrorDialog(BuildContext context, WidgetRef ref) {
    if (!kDebugMode) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Network Issue'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: Colors.orange),
            SizedBox(height: 16),
            Text('The emulator cannot reach Firebase servers.', textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              createOfflineTestConversation(context, ref);
            },
            child: const Text('Offline Demo'),
          ),
        ],
      ),
    );
  }
}

// ---------- Internal demo widgets -----------------------------------------
class _DemoHeader extends StatelessWidget {
  const _DemoHeader({required this.conversation});

  final ConversationModel conversation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: theme.colorScheme.primary,
          child: Text(MessagesDebugHelpers.getInitials(conversation.getDisplayName(''))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(conversation.getDisplayName(''), style: theme.textTheme.titleMedium)),
        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
}

class _DemoMessages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(reverse: true, children: [
      _bubble(context, 'Offline demo!', true, DateTime.now()),
      _bubble(context, 'Hello!', false, DateTime.now().subtract(const Duration(minutes: 1))),
    ]);
  }

  Widget _bubble(BuildContext context, String text, bool isMe, DateTime ts) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? cs.primary : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: TextStyle(color: isMe ? cs.onPrimary : cs.onSurface)),
            const SizedBox(height: 4),
            Text(timeago.format(ts, locale: 'en_short'), style: TextStyle(fontSize: 10, color: cs.onSurface.withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }
}

class _DemoInput extends StatefulWidget {
  const _DemoInput({required this.onSend});
  final ValueChanged<String> onSend;
  @override
  State<_DemoInput> createState() => _DemoInputState();
}

class _DemoInputState extends State<_DemoInput> {
  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration.collapsed(hintText: 'Type...'),
            onSubmitted: _submit,
          ),
        ),
        IconButton(icon: const Icon(Icons.send), onPressed: () => _submit(_controller.text)),
      ],
    );
  }
  void _submit(String text) { widget.onSend(text); _controller.clear(); }
}

/// Helper to get initials
class MessagesDebugHelpers {
  static String getInitials(String name) {
    final words = name.split(' ');
    if (words.length >= 2) {
      return (words[0][0] + words[1][0]).toUpperCase();
    }
    return words.isNotEmpty ? words[0].substring(0, 1).toUpperCase() : 'U';
  }
} 