import 'package:flutter/material.dart';

class Themes {
  static const String defaultPalette = 'pink';

  static List<DropdownMenuItem<String>> themesList = const [
    DropdownMenuItem(value: 'pink', child: Text('Pink')),
    DropdownMenuItem(value: 'purple', child: Text('Purple')),
  ];

  static ThemeData lightFromName(String? themeName) {
    final seed = _seedFromName(themeName);
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
    );
    return _withFoundation(base);
  }

  static ThemeData darkFromName(String? themeName) {
    final seed = _seedFromName(themeName);
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
    );
    return _withFoundation(base);
  }

  static Color _seedFromName(String? themeName) {
    switch (themeName) {
      case 'purple':
        return Colors.purple;
      case 'pink':
      default:
        return Colors.pink;
    }
  }

  static ThemeData _withFoundation(ThemeData base) {
    final scheme = base.colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: base.textTheme.copyWith(
        displaySmall: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
        headlineMedium: const TextStyle(fontWeight: FontWeight.w700, fontSize: 30),
        titleLarge: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        bodyLarge: const TextStyle(fontSize: 16, height: 1.35),
        bodyMedium: const TextStyle(fontSize: 15, height: 1.4),
      ),
      cardTheme: CardThemeData(
        elevation: isDark ? 0 : 1,
        margin: EdgeInsets.zero,
        color: scheme.surface.withValues(alpha: isDark ? 0.55 : 0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: isDark ? 0.5 : 0.85),
        indicatorColor: scheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: scheme.outlineVariant),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: isDark ? 0.45 : 0.9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}