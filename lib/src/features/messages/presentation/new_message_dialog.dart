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
import '../data/messaging_repository.dart';

class NewMessageDialog extends ConsumerStatefulWidget {
  const NewMessageDialog({super.key});

  @override
  ConsumerState<NewMessageDialog> createState() => _NewMessageDialogState();
}

class _NewMessageDialogState extends ConsumerState<NewMessageDialog> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  bool _isGroup = false;
  String _groupName = '';
  final Set<String> _selectedIds = {};
  final Map<String, String> _selectedUsernames = {};

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

  Future<void> _createGroup() async {
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(messagingRepositoryProvider);
    try {
      final conv = await repo.createGroupConversation(
        groupName: _groupName.trim(),
        participantIds: _selectedIds.toList(),
        participantUsernames: _selectedUsernames,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
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
        height: 500,
        child: Column(
          children: [
            // Toggle between direct and group chat
            Row(
              children: [
                const Text('Group chat'),
                const Spacer(),
                Switch(
                  value: _isGroup,
                  onChanged: (v) => setState(() {
                    _isGroup = v;
                    _selectedIds.clear();
                    _selectedUsernames.clear();
                  }),
                ),
              ],
            ),
            if (_isGroup)
              TextField(
                decoration: const InputDecoration(labelText: 'Group name'),
                onChanged: (v) => _groupName = v,
              ),
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
                      data: (list) {
                        print('[Dialog] suggestions length=${list.length}');
                        return _buildSearchResults(list);
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text(err.toString())),
                    ),
            ),
          ],
        ),
      ),
      actions: [
        if (_isGroup)
          FilledButton(
            onPressed: _selectedIds.isNotEmpty && _groupName.trim().isNotEmpty
                ? () => _createGroup()
                : null,
            child: const Text('Create Group'),
          ),
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
        if (_isGroup) {
          return CheckboxListTile(
            value: _selectedIds.contains(user.uid),
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _selectedIds.add(user.uid);
                  _selectedUsernames[user.uid] = user.username;
                } else {
                  _selectedIds.remove(user.uid);
                  _selectedUsernames.remove(user.uid);
                }
              });
            },
            title: Text(user.displayName.isNotEmpty ? user.displayName : user.username),
            subtitle: Text('@${user.username}'),
            secondary: CircleAvatar(child: Text(user.username[0].toUpperCase())),
          );
        }
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
    print('[SearchResults] size=${results.length}');
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        if (_isGroup) {
          return CheckboxListTile(
            value: _selectedIds.contains(item.uid),
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _selectedIds.add(item.uid);
                  _selectedUsernames[item.uid] = item.username;
                } else {
                  _selectedIds.remove(item.uid);
                  _selectedUsernames.remove(item.uid);
                }
              });
            },
            title: Text(item.displayName.isNotEmpty ? item.displayName : item.username),
            subtitle: Text('@${item.username}'),
            secondary: CircleAvatar(child: Text(item.username[0].toUpperCase())),
          );
        }
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