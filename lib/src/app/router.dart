/// Application routing configuration using go_router.
/// 
/// This file defines all the routes for the SnapConnect application,
/// including navigation paths and route transitions.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth.dart';
import '../features/camera/presentation/camera_screen.dart';
import '../features/camera/presentation/snap_edit_screen.dart';
import '../features/friends/presentation/friends_screen.dart';
import '../features/profile/profile.dart';
import '../features/messages/presentation/messages_screen.dart';
import '../features/stories/presentation/stories_screen.dart';
import '../features/stories/presentation/story_viewer_screen.dart';
import 'navigation_shell.dart';

/// Cache for profile setup status to avoid repeated Firebase calls
final Map<String, bool> _profileSetupCache = {};

/// Track when a user just signed up (to route them to profile setup)
bool _justSignedUp = false;

/// Mark that a user just signed up
void markUserJustSignedUp() {
  _justSignedUp = true;
}

/// Mark profile setup as completed for a user (used after saving profile).
void markProfileSetupComplete(String uid) {
  _profileSetupCache[uid] = true;
  _justSignedUp = false; // Clear sign-up flag after profile setup
}

/// Router configuration provider for the application
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authUserProvider);
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/stories', // Start at stories for existing users
    redirect: (context, state) async {
      // Get the current auth state synchronously
      final user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final currentLocation = state.matchedLocation;

      // Define auth routes that should be accessible only when logged out
      final isAuthRoute = currentLocation == '/signin' || 
                         currentLocation == '/signup';

      // Define routes that don't require redirect checks
      final isProfileSetupRoute = currentLocation == '/profile-setup';
      final isSnapEditRoute = currentLocation == '/snap-edit';

      // If not logged in and trying to access protected route, redirect to sign in
      if (!isLoggedIn && !isAuthRoute) {
        // Clear all state when user is not logged in
        _profileSetupCache.clear();
        _justSignedUp = false;
        return '/signin';
      }

      // If logged in and trying to access auth route, redirect based on profile status
      if (isLoggedIn && isAuthRoute) {
        final uid = user.uid;
        
        // Check if user just signed up
        if (_justSignedUp) {
          return '/profile-setup';
        }
        
        // Check profile setup status for existing sign-ins
        final hasCompleteProfile = await _checkProfileSetupStatus(uid, authRepository);
        if (!hasCompleteProfile) {
          return '/profile-setup';
        }
        
        return '/stories'; // Existing users with complete profiles go to stories
      }

      // Skip profile setup checks for special routes
      if (isSnapEditRoute) {
        return null;
      }

      // For logged in users, check profile setup status and route appropriately
      if (isLoggedIn && !isProfileSetupRoute) {
        final uid = user.uid;
        
        // If user just signed up, always go to profile setup
        if (_justSignedUp) {
          return '/profile-setup';
        }
        
        // Check cached or fetch profile setup status
        final hasCompleteProfile = await _checkProfileSetupStatus(uid, authRepository);
        if (!hasCompleteProfile) {
          return '/profile-setup';
        }
      }

      // No redirect needed - let navigation proceed
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/signin',
        name: 'signin',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        name: 'profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/snap-edit',
        name: 'snap-edit',
        builder: (context, state) => SnapEditScreen(
          mediaCapture: state.extra,
        ),
      ),

      // Main navigation shell with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // Camera tab (default)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'camera',
                builder: (context, state) => const CameraScreen(),
              ),
            ],
          ),
          
          // Friends tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/friends',
                name: 'friends',
                builder: (context, state) => const FriendsScreen(),
              ),
            ],
          ),
          
          // Profile tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
          
          // Messages tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/messages',
                name: 'messages',
                builder: (context, state) => const MessagesScreen(),
              ),
            ],
          ),
          
          // Stories tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stories',
                name: 'stories',
                builder: (context, state) => const StoriesScreen(),
              ),
            ],
          ),
        ],
      ),

      // Story Viewer route
      GoRoute(
        path: '/story-viewer/:userId',
        name: 'story-viewer',
        builder: (context, state) {
          final storyIndex = state.uri.queryParameters['index'];
          return StoryViewerScreen(
            userId: state.pathParameters['userId']!,
            initialIndex: storyIndex != null ? int.tryParse(storyIndex) ?? 0 : 0,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.error}',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Helper function to check profile setup status with caching
Future<bool> _checkProfileSetupStatus(String uid, AuthRepository authRepository) async {
  // Return cached result if available
  if (_profileSetupCache.containsKey(uid)) {
    return _profileSetupCache[uid]!;
  }
  
  try {
    // Fetch from Firebase and cache the result
    final hasCompleteProfile = await authRepository.hasCompletedProfileSetup(uid);
    _profileSetupCache[uid] = hasCompleteProfile;
    return hasCompleteProfile;
  } catch (e) {
    // On error, assume profile is not complete to be safe
    return false;
  }
} 