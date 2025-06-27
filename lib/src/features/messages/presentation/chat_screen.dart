/// Chat screen for individual conversations.
/// 
/// This screen displays messages in a conversation and allows users
/// to send text messages and media snaps with disappearing functionality.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../data/conversation_model.dart';
import '../data/message_model.dart';
import '../data/messages_notifier.dart';
import '../../auth/auth.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentUser = ref.watch(authUserProvider).value;
    final messagesValue = ref.watch(messagesProvider(widget.conversation.id));
    
    final displayName = widget.conversation.getDisplayName(currentUser?.uid ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: widget.conversation.isGroup 
                  ? colorScheme.tertiary 
                  : colorScheme.primary,
              child: widget.conversation.isGroup
                  ? Icon(
                      Icons.group,
                      color: colorScheme.onTertiary,
                      size: 20,
                    )
                  : Text(
                      _getInitials(displayName),
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: theme.textTheme.titleMedium,
                  ),
                  if (widget.conversation.isGroup)
                    Text(
                      '${widget.conversation.participantIds.length} participants',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
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
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _buildMessagesList(messagesValue, currentUser?.uid ?? ''),
          ),
          
          // Message input
          _buildMessageInput(colorScheme),
        ],
      ),
    );
  }

  /// Builds the messages list
  Widget _buildMessagesList(AsyncValue<List<MessageModel>> messagesValue, String currentUserId) {
    return messagesValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => _buildErrorState(err.toString()),
      data: (messages) {
        if (messages.isEmpty) return _buildEmptyState();

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMe = message.senderId == currentUserId;
            final showTimestamp = _shouldShowTimestamp(messages, index);

            return Column(
              children: [
                if (showTimestamp) _buildTimestampDivider(message.sentAt),
                _buildMessageBubble(message, isMe),
              ],
            );
          },
        );
      },
    );
  }

  /// Builds the empty state for no messages
  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send the first message to start the conversation!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds the error state
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load messages',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              ref.refresh(messagesProvider(widget.conversation.id));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Builds a timestamp divider
  Widget _buildTimestampDivider(DateTime timestamp) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider()),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _formatTimestampDivider(timestamp),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(child: Divider()),
        ],
      ),
    );
  }

  /// Builds a message bubble
  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe 
              ? colorScheme.primary 
              : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.conversation.isGroup && !isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.senderUsername,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            
            _buildMessageContent(message, isMe),
            
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeago.format(message.sentAt, locale: 'en_short'),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe 
                        ? colorScheme.onPrimary.withValues(alpha: 0.7)
                        : colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.hasBeenViewedBy(widget.conversation.getOtherParticipantId(message.senderId) ?? '') 
                        ? Icons.done_all 
                        : Icons.done,
                    size: 12,
                    color: message.hasBeenViewedBy(widget.conversation.getOtherParticipantId(message.senderId) ?? '') 
                        ? Colors.blue 
                        : colorScheme.onPrimary.withValues(alpha: 0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds message content based on type
  Widget _buildMessageContent(MessageModel message, bool isMe) {
    final colorScheme = Theme.of(context).colorScheme;
    
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content ?? '',
          style: TextStyle(
            color: isMe 
                ? colorScheme.onPrimary 
                : colorScheme.onSurface,
          ),
        );
      
      case MessageType.image:
      case MessageType.video:
      case MessageType.snap:
        return _buildMediaMessage(message, isMe);
      
      default:
        return Text(
          'Unsupported message type',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: isMe 
                ? colorScheme.onPrimary.withValues(alpha: 0.7)
                : colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        );
    }
  }

  /// Builds media message content
  Widget _buildMediaMessage(MessageModel message, bool isMe) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 200,
        maxHeight: 200,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Placeholder for media
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  message.type == MessageType.video 
                      ? Icons.play_circle_filled 
                      : Icons.image,
                  size: 48,
                  color: isMe 
                      ? colorScheme.onPrimary.withValues(alpha: 0.7)
                      : colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 8),
                Text(
                  message.type == MessageType.snap 
                      ? 'Snap' 
                      : message.type == MessageType.video 
                          ? 'Video' 
                          : 'Photo',
                  style: TextStyle(
                    fontSize: 12,
                    color: isMe 
                        ? colorScheme.onPrimary.withValues(alpha: 0.7)
                        : colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          
          // Duration indicator for snaps
          if (message.type == MessageType.snap && message.duration != null)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${message.duration}s',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the message input area
  Widget _buildMessageInput(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () => _showMediaOptions(),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: colorScheme.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onSubmitted: _sendTextMessage,
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _sendTextMessage(_messageController.text),
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

  /// Sends a text message
  void _sendTextMessage(String text) {
    if (text.trim().isEmpty) return;

    ref.read(sendTextMessageProvider(widget.conversation.id))(text.trim());
    
    _messageController.clear();
    _scrollToBottom();
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

  /// Gets initials from a name
  String _getInitials(String name) {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'U';
  }

  /// Checks if timestamp should be shown
  bool _shouldShowTimestamp(List<MessageModel> messages, int index) {
    if (index == messages.length - 1) return true;
    
    final currentMessage = messages[index];
    final nextMessage = messages[index + 1];
    
    final timeDiff = currentMessage.sentAt.difference(nextMessage.sentAt);
    return timeDiff.inHours >= 1;
  }

  /// Formats timestamp for divider
  String _formatTimestampDivider(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
} 