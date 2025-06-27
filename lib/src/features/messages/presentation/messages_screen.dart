/// Messages screen for viewing and managing conversations.
/// 
/// This screen displays a list of recent conversations with real-time updates
/// and allows users to access their direct messages and group chats.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:firebase_auth/firebase_auth.dart';

import '../data/conversations_notifier.dart';
import '../data/conversation_model.dart';
import '../data/messaging_repository.dart';
import '../../auth/auth.dart';
import 'chat_screen.dart';

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
          
          // Connection status indicator
          if (conversationsState.isFromCache)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.orange.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.cloud_off,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Offline - Showing cached conversations',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Conversations loaded: ${conversationsState.conversations.length}',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(conversationsProvider.notifier).refresh();
                    },
                    child: Text(
                      'Retry',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (conversationsState.conversations.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.green.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.cloud_done,
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Connected - ${conversationsState.conversations.length} conversations',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          
          // Error banner
          if (conversationsState.error != null && !conversationsState.isFromCache)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.red.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 16,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      conversationsState.error!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(conversationsProvider.notifier).refresh();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          
          // Conversations list
          Expanded(
            child: _buildConversationsList(
              context,
              ref,
              conversationsState,
              authUser.valueOrNull,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the conversations list widget
  Widget _buildConversationsList(
    BuildContext context,
    WidgetRef ref,
    ConversationsState conversationsState,
    User? currentUser,
  ) {
    if (conversationsState.isLoading && conversationsState.conversations.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (conversationsState.conversations.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(conversationsProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: conversationsState.conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversationsState.conversations[index];
          return _buildConversationTile(
            context,
            conversation,
            currentUser?.uid ?? '',
          );
        },
      ),
    );
  }

  /// Builds the empty state widget
  Widget _buildEmptyState(BuildContext context) {
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
            'No conversations yet',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with your friends!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              // TODO: Navigate to friends list or search
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Find Friends'),
          ),
        ],
      ),
    );
  }

  /// Builds a conversation list tile
  Widget _buildConversationTile(
    BuildContext context,
    ConversationModel conversation,
    String currentUserId,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final displayName = conversation.getDisplayName(currentUserId);
    final unreadCount = conversation.getUnreadCount(currentUserId);
    final hasUnread = unreadCount > 0;
    final lastMessageTime = conversation.lastMessageTimestamp;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: conversation.isGroup 
                  ? colorScheme.tertiary 
                  : colorScheme.primary,
              child: conversation.isGroup
                  ? Icon(
                      Icons.group,
                      color: colorScheme.onTertiary,
                    )
                  : Text(
                      _getInitials(displayName),
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
        ),
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
            if (lastMessageTime != null)
              Text(
                timeago.format(lastMessageTime, locale: 'en_short'),
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
          _openConversation(context, conversation);
        },
      ),
    );
  }

  /// Get initials from display name
  String _getInitials(String name) {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'U';
  }

  /// Shows the new message dialog
  void _showNewMessageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Message'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                hintText: 'Search for friends to message',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Friend search will be implemented with the friends feature.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            // Debug option for testing
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'DEBUG: Test Messaging',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _testFirestoreConnectivity(context, ref);
                          },
                          child: const Text('Test Firestore'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _createTestConversation(context, ref);
                          },
                          child: const Text('Create Test Chat'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
                  content: Text('Friend search will be available with the friends feature'),
                ),
              );
            },
            child: const Text('Start Chat'),
          ),
        ],
      ),
    );
  }

  /// Tests Firestore connectivity and permissions
  void _testFirestoreConnectivity(BuildContext context, WidgetRef ref) async {
    try {
      // Show testing dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Expanded(
                child: Text('Testing Firestore connectivity and permissions...'),
              ),
            ],
          ),
        ),
      );

      // Test messaging repository connectivity
      final repository = ref.read(messagingRepositoryProvider);
      final canConnect = await repository.testFirestoreConnectivity();

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close testing dialog

      // Show results
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                canConnect ? Icons.check_circle : Icons.error,
                color: canConnect ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(canConnect ? 'Connection OK' : 'Connection Failed'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                canConnect 
                    ? 'Firestore is accessible and security rules are working!'
                    : 'Firestore connection or permissions issue detected.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: canConnect ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              if (canConnect) ...[
                const Text('✅ Network connectivity: OK'),
                const Text('✅ Firebase authentication: OK'),
                const Text('✅ Firestore security rules: OK'),
                const Text('✅ Basic read permissions: OK'),
                const SizedBox(height: 16),
                const Text('Messaging system is ready! Try the interactive demo below.'),
              ] else ...[
                const Text('❌ Firestore not accessible'),
                const SizedBox(height: 12),
                const Text('Possible causes:'),
                const Text('• Network connectivity issues'),
                const Text('• Firebase authentication problems'),
                const Text('• Firestore security rules not deployed'),
                const Text('• App configuration issues'),
                const SizedBox(height: 16),
                const Text('Try the offline demo instead.'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
                          if (canConnect)
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _createOfflineTestConversation(context, ref);
                  },
                  child: const Text('Try Demo Chat'),
                )
            else
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _createOfflineTestConversation(context, ref);
                },
                child: const Text('Offline Demo'),
              ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close testing dialog

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Test Failed'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Failed to test Firestore connectivity:'),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _createOfflineTestConversation(context, ref);
              },
              child: const Text('Try Offline Demo'),
            ),
          ],
        ),
      );
    }
  }

  /// Creates a test conversation for debugging messaging functionality
  void _createTestConversation(BuildContext context, WidgetRef ref) async {
    try {
      // Show loading with timeout
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Expanded(
                child: Text('Creating test conversation...\nThis may take a moment in emulator.'),
              ),
            ],
          ),
        ),
      );

      // Get current user for self-conversation test
      final authUser = ref.read(authUserProvider).value;
      if (authUser == null) {
        throw Exception('User not authenticated');
      }

      // Add timeout to prevent hanging
      final conversation = await ref
          .read(conversationsProvider.notifier)
          .createOrGetDirectConversation(
            otherUserId: authUser.uid,
            otherUsername: 'Test Self-Chat',
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Connection timeout - emulator network issues detected');
            },
          );

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      if (conversation != null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test conversation created! You can now test messaging.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to create test conversation');
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog
      
      // Check if this is a network issue
      final isNetworkError = e.toString().toLowerCase().contains('timeout') ||
                           e.toString().toLowerCase().contains('host') ||
                           e.toString().toLowerCase().contains('network');
      
      if (isNetworkError) {
        // Show network-specific error with option to create offline test
        _showNetworkErrorDialog(context, ref);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating test conversation: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Shows network error dialog with offline test option
  void _showNetworkErrorDialog(BuildContext context, WidgetRef ref) {
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Network Issue'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'The emulator cannot reach Firebase servers. This is normal in some emulator configurations.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Options:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Try running on a physical device'),
            Text('• Use the offline demo mode below'),
            Text('• Check emulator network settings'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _createOfflineTestConversation(context, ref);
            },
            child: const Text('Create Offline Demo'),
          ),
        ],
      ),
    );
  }

  /// Creates an offline test conversation without Firebase
  void _createOfflineTestConversation(BuildContext context, WidgetRef ref) {
    // Create a fake conversation object for local testing
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

    // Show the fake conversation in the chat dialog
    _openConversation(context, fakeConversation);
    
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Offline demo conversation created! This simulates the messaging UI.'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// Opens a conversation chat screen
  void _openConversation(BuildContext context, ConversationModel conversation) {
    final isOfflineDemo = conversation.id == 'offline_test_conversation';
    
    if (isOfflineDemo) {
      // Show the demo dialog for offline testing
      _showDemoDialog(context, conversation);
    } else {
      // Navigate to the proper ChatScreen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatScreen(conversation: conversation),
        ),
      );
    }
  }

  /// Shows the demo dialog for offline testing
  void _showDemoDialog(BuildContext context, ConversationModel conversation) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: conversation.isGroup 
                        ? Theme.of(context).colorScheme.tertiary 
                        : Theme.of(context).colorScheme.primary,
                    child: conversation.isGroup
                        ? Icon(
                            Icons.group,
                            color: Theme.of(context).colorScheme.onTertiary,
                          )
                        : Text(
                            _getInitials(conversation.getDisplayName('')),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conversation.getDisplayName(''),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Offline Demo Mode',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              
              // Messages area
              Expanded(
                child: _buildDemoMessages(context),
              ),
              
              // Message input
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: () => _showDemoMediaOptions(context),
                    ),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (text) => _sendDemoMessage(context, text),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => _sendDemoMessage(context, 'Demo message!'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds demo messages for offline testing
  Widget _buildDemoMessages(BuildContext context) {
    return ListView(
      reverse: true,
      children: [
        _buildDemoMessageBubble(context, 'Hey! How are you?', false, DateTime.now().subtract(const Duration(minutes: 5))),
        _buildDemoMessageBubble(context, 'I\'m doing great! Just testing the messaging system.', true, DateTime.now().subtract(const Duration(minutes: 4))),
        _buildDemoMessageBubble(context, '📸 Sent a snap', false, DateTime.now().subtract(const Duration(minutes: 2))),
        _buildDemoMessageBubble(context, 'Nice! This messaging interface looks awesome!', true, DateTime.now().subtract(const Duration(minutes: 1))),
        Center(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(height: 8),
                Text(
                  'Demo Mode Active',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This demonstrates the messaging UI. Real functionality requires network connectivity.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a demo message bubble
  Widget _buildDemoMessageBubble(BuildContext context, String text, bool isMe, DateTime timestamp) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.6,
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
            Text(
              text,
              style: TextStyle(
                color: isMe 
                    ? colorScheme.onPrimary 
                    : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeago.format(timestamp, locale: 'en_short'),
              style: TextStyle(
                fontSize: 10,
                color: isMe 
                    ? colorScheme.onPrimary.withValues(alpha: 0.7)
                    : colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }



  /// Sends a demo message
  void _sendDemoMessage(BuildContext context, String text) {
    if (text.trim().isEmpty) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Demo: Would send "$text"'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Shows demo media options
  void _showDemoMediaOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Demo Media Options',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.of(context).pop();
                _sendDemoMessage(context, '📸 Photo');
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Record Video'),
              onTap: () {
                Navigator.of(context).pop();
                _sendDemoMessage(context, '🎥 Video');
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Send Snap'),
              onTap: () {
                Navigator.of(context).pop();
                _sendDemoMessage(context, '⏰ Disappearing Snap');
              },
            ),
          ],
        ),
      ),
    );
  }
} 