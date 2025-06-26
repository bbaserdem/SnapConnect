// Main navigation shell widget that provides the bottom navigation bar.
//
// This widget hosts the five primary navigation destinations:
// Camera, Friends, Profile, Messages, and Stories.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../common/widgets/debug_info_banner.dart';

/// Navigation shell widget that provides the bottom navigation bar
class NavigationShell extends StatelessWidget {
  /// Creates a navigation shell widget
  const NavigationShell({required this.navigationShell, super.key});

  /// The navigation shell from go_router
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined, size: 24),
            selectedIcon: Icon(Icons.camera_alt, size: 24),
            label: 'Camera',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined, size: 24),
            selectedIcon: Icon(Icons.people, size: 24),
            label: 'Friends',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, size: 24),
            selectedIcon: Icon(Icons.person, size: 24),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline, size: 24),
            selectedIcon: Icon(Icons.chat_bubble, size: 24),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined, size: 24),
            selectedIcon: Icon(Icons.auto_stories, size: 24),
            label: 'Stories',
          ),
        ],
      ),
    );
  }
}
