/// Dialog for sending friend requests with username autocomplete.
///
/// As the user types, we show up to 10 usernames that start with the query.
/// Selecting a suggestion will fill the field and allow sending.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/friends_notifier.dart';
import '../data/user_search_provider.dart';

class AddFriendDialog extends ConsumerStatefulWidget {
  const AddFriendDialog({super.key});

  @override
  ConsumerState<AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends ConsumerState<AddFriendDialog> {
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
      setState(() {
        _query = value.trim();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = ref.watch(usernameSearchProvider(_query));

    return AlertDialog(
      title: const Text('Add Friend'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            onChanged: _onChanged,
            decoration: const InputDecoration(
              hintText: 'Enter username',
              prefixIcon: Icon(Icons.person_search),
            ),
          ),
          const SizedBox(height: 12),
          // Suggestions
          suggestions.when(
            data: (list) {
              if (list.isEmpty || _query.isEmpty) {
                return const SizedBox.shrink();
              }
              return SizedBox(
                height: 200,
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return ListTile(
                      title: Text(item.username),
                      subtitle: item.displayName.isNotEmpty ? Text(item.displayName) : null,
                      onTap: () {
                        _controller.text = item.username;
                        setState(() {
                          _query = item.username;
                        });
                      },
                    );
                  },
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 16),
              child: CircularProgressIndicator(),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(err.toString(), style: const TextStyle(color: Colors.red)),
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
          onPressed: () async {
            final username = _controller.text.trim();
            if (username.isEmpty) return;
            final parentContext = context;
            try {
              // Need to map username to uid first via suggestions result.
              // Simpler: perform exact search again.
              final results = await ref
                  .read(userSearchRepositoryProvider)
                  .search(username, limit: 1);
              if (results.isEmpty) {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(content: Text('User not found')),
                );
                return;
              }
              final targetUid = results.first.uid;
              await ref.read(friendsProvider.notifier).sendRequest(targetUid);
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(content: Text('Friend request sent to $username')),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(parentContext).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          },
          child: const Text('Send'),
        ),
      ],
    );
  }
} 