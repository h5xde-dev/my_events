import 'package:flutter/material.dart';

class Themes {
  static List<DropdownMenuItem<String>> themesList = [
    DropdownMenuItem(
      child: Text('Pink'),
      value: 'pink',
    ),
    DropdownMenuItem(
      child: Text('Purple'),
      value: 'purple',
    ),
  ];

  static ThemeData fromName(String? themeName) {
    switch (themeName) {
      case 'purple':
        return purple();
      case 'pink':
      default:
        return pink();
    }
  }

  static ThemeData pink() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.pink,
        primary: Colors.pink,
        secondary: Colors.purple,
        surface: Colors.white,
      ),
    );
    return _withFoundation(base);
  }

  static ThemeData purple() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.purple,
        primary: Colors.purple,
        secondary: Colors.purpleAccent,
        surface: Colors.white,
      ),
    );
    return _withFoundation(base);
  }

  static ThemeData _withFoundation(ThemeData base) {
    final scheme = base.colorScheme;
    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: base.textTheme.copyWith(
        headlineMedium: const TextStyle(fontWeight: FontWeight.w700, fontSize: 28),
        titleLarge: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        bodyMedium: const TextStyle(fontSize: 15, height: 1.4),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white.withValues(alpha: 0.16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.onSurface,
        contentTextStyle: TextStyle(color: scheme.surface),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}