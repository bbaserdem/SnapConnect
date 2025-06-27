/// New Message dialog for starting a chat with a friend.
///
/// Displays a debounced search field backed by the `usernameSearchProvider`.
/// When the user selects a friend from the suggestions we either create or
/// fetch the direct conversation via `ConversationsNotifier` and navigate to
/// the `ChatScreen`.
///
/// This replaces the previous debug-oriented dialog that exposed Firestore
/// connectivity tests.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../friends/data/user_search_provider.dart';
import '../../friends/data/friends_notifier.dart';
import '../../profile/data/public_user_provider.dart';
import '../data/conversations_notifier.dart';
import 'chat_screen.dart';
import '../../friends/data/user_search_repository.dart';

class NewMessageDialog extends ConsumerStatefulWidget {
  const NewMessageDialog({super.key});

  @override
  ConsumerState<NewMessageDialog> createState() => _NewMessageDialogState();
}

class _NewMessageDialogState extends ConsumerState<NewMessageDialog> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _query = value.trim());
    });
  }

  Future<void> _startChat({required String uid, required String username}) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final conv = await ref.read(conversationsProvider.notifier).createOrGetDirectConversation(
            otherUserId: uid,
            otherUsername: username,
          );
      if (!mounted) return;
      if (conv == null) {
        messenger.showSnackBar(const SnackBar(content: Text('Failed to create conversation')));
        return;
      }
      Navigator.of(context).pop(); // close dialog before navigating
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ChatScreen(conversation: conv)),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = ref.watch(usernameSearchProvider(_query));
    // Accepted friends for default list when query is empty.
    final friendIds = ref.watch(acceptedFriendIdsProvider);
    final friendProfiles = friendIds
        .map((uid) => ref.watch(publicUserProvider(uid)))
        .where((async) => async.hasValue)
        .map((async) => async.value!)
        .toList()
      ..sort((a, b) => a.username.compareTo(b.username));

    return AlertDialog(
      title: const Text('New Message'),
      content: SizedBox(
        width: 400,
        height: 400,
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: _onChanged,
              decoration: const InputDecoration(
                hintText: 'Search friends',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _query.isEmpty
                  ? _buildFriendsList(friendProfiles)
                  : suggestions.when(
                      data: (list) => _buildSearchResults(list),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text(err.toString())),
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildFriendsList(List<PublicUser> friends) {
    if (friends.isEmpty) {
      return const Center(child: Text('No friends yet'));
    }
    return ListView.builder(
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final user = friends[index];
        return ListTile(
          leading: CircleAvatar(child: Text(user.username[0].toUpperCase())),
          title: Text(user.displayName.isNotEmpty ? user.displayName : user.username),
          subtitle: Text('@${user.username}'),
          onTap: () => _startChat(uid: user.uid, username: user.username),
        );
      },
    );
  }

  Widget _buildSearchResults(List<UserSearchResult> results) {
    if (results.isEmpty) return const Center(child: Text('No users found'));
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          leading: CircleAvatar(child: Text(item.username[0].toUpperCase())),
          title: Text(item.displayName.isNotEmpty ? item.displayName : item.username),
          subtitle: Text('@${item.username}'),
          onTap: () => _startChat(uid: item.uid, username: item.username),
        );
      },
    );
  }
} 