/// Chat screen for individual conversations.
/// 
/// This screen displays messages in a conversation and allows users
/// to send text messages and media snaps with disappearing functionality.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/conversation_model.dart';
import '../data/messages_notifier.dart';
import '../../auth/auth.dart';
import '../data/messaging_repository.dart';
import 'chat_header.dart';
import 'chat_input_bar.dart';
import 'chat_messages_list.dart';

/// Chat screen widget for individual conversations
class ChatScreen extends ConsumerStatefulWidget {
  final ConversationModel conversation;

  const ChatScreen({
    super.key,
    required this.conversation,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authUserProvider).value;
    final messagesValue = ref.watch(messagesProvider(widget.conversation.id));
    
    return Scaffold(
      appBar: AppBar(
        title: ChatHeader(conversation: widget.conversation, currentUserId: currentUser?.uid ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video call coming soon!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Voice call coming soon!')),
              );
            },
          ),
          if (widget.conversation.isGroup)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'leave') _leaveGroup();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'leave',
                  child: Text('Leave Group'),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ChatMessagesList(
              messagesValue: messagesValue,
              conversation: widget.conversation,
              currentUserId: currentUser?.uid ?? '',
              scrollController: _scrollController,
            ),
          ),
          
          // Message input
          ChatInputBar(
            onSend: (text) {
              ref.read(sendTextMessageProvider(widget.conversation.id))(text);
              _scrollToBottom();
            },
            onShowMediaOptions: _showMediaOptions,
          ),
        ],
      ),
    );
  }

  /// Shows media options for sending snaps
  void _showMediaOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Camera integration coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Record Video'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Video recording coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gallery selection coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Scrolls to the bottom of the messages list
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _leaveGroup() async {
    final repo = ref.read(messagingRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await repo.leaveConversation(widget.conversation.id);
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('You left the group')));
      Navigator.of(context).pop(); // exit chat screen
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }
} 