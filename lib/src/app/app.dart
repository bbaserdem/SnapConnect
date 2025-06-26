// Main application widget that configures routing, theme, and global providers.
//
// This file serves as the root of the SnapConnect application, setting up
// the MaterialApp with go_router for navigation and applying the app theme.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';

/// Root application widget wrapped with Riverpod for state management
class SnapConnectApp extends ConsumerWidget {
  const SnapConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'SnapConnect',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
