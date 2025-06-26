/// Profile screen for viewing and editing user profile information.
/// 
/// This screen displays the current user's profile including their bio,
/// interests, and provides options to edit profile information.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/auth.dart';

/// Main profile screen widget
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = ref.watch(authUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog(context, ref);
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : _buildProfileWithCache(context, ref, user, theme, colorScheme),
    );
  }

  /// Build profile with caching to improve performance
  Widget _buildProfileWithCache(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
      future: ref.read(authRepositoryProvider).getUserDocument(user.uid),
      builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading profile',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final userData = snapshot.data?.data();
                if (userData == null) {
                  return const Center(
                    child: Text('Profile not found'),
                  );
                }

                return _buildProfileContent(context, user, userData, theme, colorScheme);
              },
            );
  }

  /// Builds the main profile content
  Widget _buildProfileContent(
    BuildContext context,
    dynamic user,
    Map<String, dynamic> userData,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final username = userData['username'] as String? ?? 'Unknown';
    final bio = userData['bio'] as String? ?? '';
    final interestTags = userData['interest_tags'] as List? ?? [];

    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primary.withValues(alpha: 0.1),
                  colorScheme.surface,
                ],
              ),
            ),
            child: Column(
              children: [
                // Profile avatar
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      username.isNotEmpty ? username[0].toUpperCase() : 'U',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Username
                Text(
                  '@$username',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                
                // Email
                Text(
                  user.email ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Profile sections
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bio section
                _buildProfileSection(
                  context,
                  title: 'About Me',
                  content: bio.isNotEmpty ? bio : 'No bio added yet',
                  icon: Icons.person_outline,
                  isEmpty: bio.isEmpty,
                  theme: theme,
                  colorScheme: colorScheme,
                ),
                
                const SizedBox(height: 16),
                
                // Interests section
                _buildInterestsSection(
                  context,
                  interestTags: List<String>.from(interestTags),
                  theme: theme,
                  colorScheme: colorScheme,
                ),
                
                const SizedBox(height: 16),
                
                // Stats section
                _buildStatsSection(context, theme, colorScheme),
                
                const SizedBox(height: 24),
                
                // Edit profile button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      _showEditProfileDialog(context, userData);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a profile section card
  Widget _buildProfileSection(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    required bool isEmpty,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isEmpty 
                    ? colorScheme.onSurface.withValues(alpha: 0.5)
                    : colorScheme.onSurface,
                fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the interests section
  Widget _buildInterestsSection(
    BuildContext context, {
    required List<String> interestTags,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.interests,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Interests',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (interestTags.isEmpty)
              Text(
                'No interests selected yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: interestTags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    backgroundColor: colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds the stats section
  Widget _buildStatsSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Stats',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  label: 'Snaps Sent',
                  value: '0',
                  theme: theme,
                  colorScheme: colorScheme,
                ),
                _buildStatItem(
                  context,
                  label: 'Stories Posted',
                  value: '0',
                  theme: theme,
                  colorScheme: colorScheme,
                ),
                _buildStatItem(
                  context,
                  label: 'Friends',
                  value: '0',
                  theme: theme,
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single stat item
  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  /// Shows the edit profile dialog
  void _showEditProfileDialog(BuildContext context, Map<String, dynamic> userData) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit profile functionality coming in Phase 1.3!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// Shows the settings dialog
  void _showSettingsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Text('Settings functionality coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(authStateNotifierProvider.notifier).signOut();
                if (context.mounted) {
                  context.go('/signin');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error signing out: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}