/// Application routing configuration using go_router.
/// 
/// This file defines all the routes for the SnapConnect application,
/// including navigation paths and route transitions.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/auth/auth.dart';

/// Router configuration provider for the application
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authUserProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // Get the current auth state
      final isLoggedIn = authState.valueOrNull != null;

      // Get the current location
      final currentLocation = state.matchedLocation;

      // Define auth routes that should be accessible only when logged out
      final isAuthRoute = currentLocation == '/signin' || 
                         currentLocation == '/signup' ||
                         currentLocation == '/profile-setup';

      // If not logged in and trying to access protected route, redirect to sign in
      if (!isLoggedIn && !isAuthRoute) {
        return '/signin';
      }

      // If logged in and trying to access auth route, redirect to home
      if (isLoggedIn && isAuthRoute) {
        return '/';
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

      // Protected routes
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Error: ${state.error}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    ),
  );
}); 