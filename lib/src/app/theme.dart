/// Application theme configuration with Blue and Orange color scheme.
/// 
/// This file defines the light and dark themes for the SnapConnect application,
/// implementing the color scheme specified in the design requirements.

import 'package:flutter/material.dart';

/// Application theme configuration class
class AppTheme {
  // Primary Colors - Blue and Orange
  static const Color _vibrantBlue = Color(0xFF005af5);
  static const Color _vibrantOrange = Color(0xFFeb430c);
  static const Color _lightBlue = Color(0xFF6699ff);
  static const Color _lightOrange = Color(0xFFff6640);

  /// Light theme configuration
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _lightBlue,
      brightness: Brightness.light,
    ).copyWith(
      primary: _lightBlue,
      secondary: _lightOrange,
      tertiary: _lightOrange,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  /// Dark theme configuration
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _lightBlue,
      brightness: Brightness.dark,
    ).copyWith(
      secondary: _lightOrange,
      tertiary: _lightOrange,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
} 