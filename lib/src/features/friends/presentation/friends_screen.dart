/// Friends screen for managing friend lists and friend requests.
/// 
/// This screen allows users to view their current friends list,
/// search for new friends, and manage friend requests.

/// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../data/friends_notifier.dart';
import 'add_friend_dialog.dart';
import 'package:snapconnect/src/features/profile/data/public_user_provider.dart';
import '../data/user_search_provider.dart';

/// Main friends screen widget
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  String query = '';
  Timer? _debounce;

  @override
  bool get wantKeepAlive => true; // Keep state alive for better UX

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final friendsState = ref.watch(friendsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: const [],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(text: 'My Friends'),
            Tab(text: 'Search'),
            Tab(text: 'Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFriendsList(friendsState),
          _buildSearchTab(),
          _buildRequestsList(friendsState),
        ],
      ),
    );
  }

  /// Builds the friends list tab
  Widget _buildFriendsList(FriendsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return StatefulBuilder(
      builder: (context, setStateSB) {
        String query = '';
        final filtered = query.isEmpty
            ? state.acceptedIds
            : state.acceptedIds.where((uid) {
                final userAsync = ref.watch(publicUserProvider(uid));
                return userAsync.when(
                  data: (user) => user.username.toLowerCase().contains(query.toLowerCase()) ||
                      user.displayName.toLowerCase().contains(query.toLowerCase()),
                  loading: () => false,
                  error: (_, __) => false,
                );
              }).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No friends found'));
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search friends',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setStateSB(() { query = v.trim(); }),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  return _FriendTile(uid: filtered[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds the friend requests list tab
  Widget _buildRequestsList(FriendsState state) {
    final incoming = state.incoming;
    final outgoing = state.outgoing;

    if (state.isLoading && incoming.isEmpty && outgoing.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (incoming.isEmpty && outgoing.isEmpty) {
      return const Center(child: Text('No friend requests'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (incoming.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Incoming', style: Theme.of(context).textTheme.labelLarge),
          ),
          ...incoming.map((req) => _RequestTile(
                uid: req.friendUid,
                onAccept: () => ref.read(friendsProvider.notifier).acceptRequest(req.friendUid),
                onDecline: () => ref.read(friendsProvider.notifier).removeRelationship(req.friendUid),
              )),
          const SizedBox(height: 12),
        ],
        if (outgoing.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Sent', style: Theme.of(context).textTheme.labelLarge),
          ),
          ...outgoing.map((req) => _PendingTile(
                uid: req.friendUid,
                onCancel: () => ref.read(friendsProvider.notifier).removeRelationship(req.friendUid),
              )),
        ],
      ],
    );
  }

  /// Builds the search tab
  Widget _buildSearchTab() {
    return StatefulBuilder(
      builder: (context, setStateSB) {
        final suggestions = ref.watch(usernameSearchProvider(query));
        final acceptedIds = ref.watch(acceptedFriendIdsProvider);
        final pendingIds = ref.watch(friendsProvider).outgoing.map((e) => e.friendUid).toSet();

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search users',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 300), () {
                    setStateSB(() => query = v.trim().toLowerCase());
                  });
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: suggestions.when(
                  data: (list) {
                    print('[FriendsSearch] results len=${list.length}');
                    if (list.isEmpty) return const Center(child: Text('No users found'));
                    return ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];
                        final isFriend = acceptedIds.contains(item.uid);
                        final isPending = pendingIds.contains(item.uid);
                        return ListTile(
                          leading: CircleAvatar(child: Text(item.username[0].toUpperCase())),
                          title: Text(item.displayName.isNotEmpty ? item.displayName : item.username),
                          subtitle: Text('@${item.username}'),
                          trailing: isFriend
                              ? const Icon(Icons.check, color: Colors.green)
                              : isPending
                                  ? const Icon(Icons.hourglass_top_rounded, color: Colors.orange)
                                  : IconButton(
                                      icon: const Icon(Icons.person_add),
                                      onPressed: () async {
                                        await ref.read(friendsProvider.notifier).sendRequest(item.uid);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Friend request sent to ${item.username}')),
                                        );
                                      },
                                    ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text(err.toString())),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shows the add friend dialog
  void _showAddFriendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const AddFriendDialog(),
    );
  }

  /// Handles friend actions from the popup menu
  void _handleFriendAction(String action, String friendName) {
    String message = '';
    switch (action) {
      case 'message':
        message = 'Opening chat with $friendName...';
        break;
      case 'block':
        message = 'Blocked $friendName';
        break;
      case 'remove':
        message = 'Removed $friendName from friends';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$message (Feature will be implemented later)'),
      ),
    );
  }
}

/// Friend tile that resolves uid to public profile info.
class _FriendTile extends ConsumerWidget {
  final String uid;
  const _FriendTile({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(publicUserProvider(uid));
    final colorScheme = Theme.of(context).colorScheme;

    return userAsync.when(
      loading: () => const ListTile(title: Text('Loading...')),
      error: (err, _) => ListTile(title: Text(uid)),
      data: (user) {
        final avatarText = user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U';
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primary,
              child: Text(avatarText, style: TextStyle(color: colorScheme.onPrimary)),
            ),
            title: Text(user.displayName.isNotEmpty ? user.displayName : user.username),
            subtitle: Text('@${user.username}'),
            trailing: Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}

/// Incoming request tile
class _RequestTile extends ConsumerWidget {
  final String uid;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _RequestTile({required this.uid, required this.onAccept, required this.onDecline});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(publicUserProvider(uid));
    final colorScheme = Theme.of(context).colorScheme;

    return userAsync.when(
      loading: () => const ListTile(title: Text('Loading...')),
      error: (err, _) => ListTile(title: Text(uid)),
      data: (user) {
        final avatarText = user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U';
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.secondary,
              child: Text(avatarText, style: TextStyle(color: colorScheme.onSecondary)),
            ),
            title: Text(user.displayName.isNotEmpty ? user.displayName : user.username),
            subtitle: Text('@${user.username}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: onAccept),
                IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: onDecline),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Outgoing request (pending) tile
class _PendingTile extends ConsumerWidget {
  final String uid;
  final VoidCallback onCancel;

  const _PendingTile({required this.uid, required this.onCancel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(publicUserProvider(uid));
    final colorScheme = Theme.of(context).colorScheme;

    return userAsync.when(
      loading: () => const ListTile(title: Text('Loading...')),
      error: (err, _) => ListTile(title: Text(uid)),
      data: (user) {
        final avatarText = user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U';
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Text(avatarText, style: TextStyle(color: colorScheme.onPrimaryContainer)),
            ),
            title: Text(user.displayName.isNotEmpty ? user.displayName : user.username),
            subtitle: Text('@${user.username} • Pending'),
            trailing: IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: onCancel,
            ),
          ),
        );
      },
    );
  }
} 