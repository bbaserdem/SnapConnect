/// Application routing configuration using go_router.
/// 
/// This file defines all the routes for the SnapConnect application,
/// including navigation paths and route transitions.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camerawesome/camerawesome_plugin.dart';

import '../features/auth/auth.dart';
import '../features/camera/presentation/camera_screen.dart';
import '../features/camera/presentation/snap_edit_screen.dart';
import '../features/friends/presentation/friends_screen.dart';
import '../features/profile/profile.dart';
import '../features/messages/presentation/messages_screen.dart';
import '../features/stories/presentation/stories_screen.dart';
import 'navigation_shell.dart';

/// Router configuration provider for the application
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authUserProvider);
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      // Get the current auth state
      final user = authState.valueOrNull;
      final isLoggedIn = user != null;

      // Get the current location
      final currentLocation = state.matchedLocation;

      // Define auth routes that should be accessible only when logged out
      final isAuthRoute = currentLocation == '/signin' || 
                         currentLocation == '/signup';

      // Define routes that don't require redirect checks
      final isProfileSetupRoute = currentLocation == '/profile-setup';

      // If not logged in and trying to access protected route, redirect to sign in
      if (!isLoggedIn && !isAuthRoute) {
        return '/signin';
      }

      // If logged in and trying to access auth route, redirect based on profile status
      if (isLoggedIn && isAuthRoute) {
        // Check if user has completed profile setup
        try {
          final hasCompletedSetup = await authRepository.hasCompletedProfileSetup(user.uid);
          return hasCompletedSetup ? '/' : '/profile-setup';
        } catch (e) {
          // If there's an error checking profile status, assume profile setup is needed
          return '/profile-setup';
        }
      }

      // If logged in and not on profile setup route, check if profile setup is complete
      if (isLoggedIn && !isProfileSetupRoute) {
        try {
          final hasCompletedSetup = await authRepository.hasCompletedProfileSetup(user.uid);
          if (!hasCompletedSetup) {
            return '/profile-setup';
          }
        } catch (e) {
          // If there's an error checking profile status, redirect to profile setup
          return '/profile-setup';
        }
      }

      // No redirect needed
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
          mediaCapture: state.extra as MediaCapture,
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