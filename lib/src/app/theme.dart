/// Application theme configuration with Blue and Orange color scheme.
/// 
/// This file defines the light and dark themes for the SnapConnect application,
/// implementing the color scheme specified in the design requirements.

import 'package:flutter/material.dart';

/// Application theme configuration class
class AppTheme {
  // Primary Colors - Blue and Orange
  static const Color _lightBlue = Color(0xFF6699ff);
  static const Color _lightOrange = Color(0xFFff6640);

  /// Common app bar theme configuration
  static const AppBarTheme _appBarTheme = AppBarTheme(
    centerTitle: true,
    elevation: 0,
  );

  /// Common elevated button theme configuration
  static final ElevatedButtonThemeData _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  /// Common card theme configuration
  static final CardThemeData _cardTheme = CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  );

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
    appBarTheme: _appBarTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    cardTheme: _cardTheme,
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
    appBarTheme: _appBarTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    cardTheme: _cardTheme,
  );
} 