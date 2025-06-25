/// Friends screen for managing friend lists and friend requests.
/// 
/// This screen allows users to view their current friends list,
/// search for new friends, and manage friend requests.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Main friends screen widget
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              _showAddFriendDialog(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(text: 'My Friends'),
            Tab(text: 'Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFriendsList(),
          _buildRequestsList(),
        ],
      ),
    );
  }

  /// Builds the friends list tab
  Widget _buildFriendsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5, // Placeholder count
      itemBuilder: (context, index) {
        return _buildFriendTile(
          name: 'Friend ${index + 1}',
          username: '@friend${index + 1}',
          avatarText: 'F${index + 1}',
          isOnline: index % 2 == 0,
        );
      },
    );
  }

  /// Builds the friend requests list tab
  Widget _buildRequestsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3, // Placeholder count
      itemBuilder: (context, index) {
        return _buildRequestTile(
          name: 'User ${index + 1}',
          username: '@user${index + 1}',
          avatarText: 'U${index + 1}',
        );
      },
    );
  }

  /// Builds a friend list tile
  Widget _buildFriendTile({
    required String name,
    required String username,
    required String avatarText,
    required bool isOnline,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: colorScheme.primary,
              child: Text(
                avatarText,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(name),
        subtitle: Text(username),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            _handleFriendAction(value, name);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'message',
              child: Row(
                children: [
                  Icon(Icons.message),
                  SizedBox(width: 8),
                  Text('Send Message'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block),
                  SizedBox(width: 8),
                  Text('Block'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.person_remove),
                  SizedBox(width: 8),
                  Text('Remove Friend'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a friend request tile
  Widget _buildRequestTile({
    required String name,
    required String username,
    required String avatarText,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.secondary,
          child: Text(
            avatarText,
            style: TextStyle(
              color: colorScheme.onSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(name),
        subtitle: Text(username),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.check, color: Colors.green),
              onPressed: () {
                _handleRequestAction('accept', name);
              },
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: () {
                _handleRequestAction('decline', name);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Shows the add friend dialog
  void _showAddFriendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Friend'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Enter username or email',
            prefixIcon: Icon(Icons.search),
          ),
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
                  content: Text('Friend search will be implemented in Phase 1.6'),
                ),
              );
            },
            child: const Text('Search'),
          ),
        ],
      ),
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

  /// Handles friend request actions
  void _handleRequestAction(String action, String userName) {
    final message = action == 'accept'
        ? 'Accepted friend request from $userName'
        : 'Declined friend request from $userName';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$message (Feature will be implemented later)'),
      ),
    );
  }
} 