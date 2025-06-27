/// Main navigation shell widget that provides the bottom navigation bar.
/// 
/// This widget hosts the five primary navigation destinations:
/// Camera, Friends, Profile, Messages, and Stories.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../common/widgets/debug_info_banner.dart';
import '../features/friends/data/friends_notifier.dart';

/// Navigation shell widget that provides the bottom navigation bar with a
/// notification badge on the Friends tab when the user has **incoming** friend
/// requests.
class NavigationShell extends ConsumerWidget {
  /// Creates a navigation shell widget
  const NavigationShell({
    required this.navigationShell,
    super.key,
  });

  /// The go_router navigation shell
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Listen only to the **count** of incoming requests so that the bottom
    // navigation bar rebuilds only when the badge number changes.
    final incomingCount = ref.watch(
      friendsProvider.select((s) => s.incoming.length),
    );

    return Scaffold(
      body: Column(
        children: [
          const DebugInfoBanner(),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          // Navigate directly without delay to prevent navigation issues
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        destinations: [
          const NavigationDestination(
            icon: Icon(
              Icons.camera_alt_outlined,
              size: 24,
            ),
            selectedIcon: Icon(
              Icons.camera_alt,
              size: 24,
            ),
            label: 'Camera',
          ),
          NavigationDestination(
            icon: _FriendsIconWithBadge(
              hasNotification: incomingCount > 0,
              selected: false,
            ),
            selectedIcon: _FriendsIconWithBadge(
              hasNotification: incomingCount > 0,
              selected: true,
            ),
            label: 'Friends',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
              size: 24,
            ),
            selectedIcon: Icon(
              Icons.person,
              size: 24,
            ),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.chat_bubble_outline,
              size: 24,
            ),
            selectedIcon: Icon(
              Icons.chat_bubble,
              size: 24,
            ),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.auto_stories_outlined,
              size: 24,
            ),
            selectedIcon: Icon(
              Icons.auto_stories,
              size: 24,
            ),
            label: 'Stories',
          ),
        ],
      ),
    );
  }
}

/// Friends tab icon with optional red notification dot.
class _FriendsIconWithBadge extends StatelessWidget {
  const _FriendsIconWithBadge({
    required this.hasNotification,
    required this.selected,
  });

  /// Whether to show the red dot.
  final bool hasNotification;

  /// Whether the destination is selected – uses the filled variant of the
  /// icon.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final icon = selected ? Icons.people : Icons.people_outlined;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, size: 24),
        if (hasNotification)
          Positioned(
            right: -1,
            top: -1,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
} 