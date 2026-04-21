import 'package:flutter/material.dart';
import 'package:my_events/data_static/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Customisation {
  static const _themePaletteKey = 'theme_palette';
  static const _themeModeKey = 'theme_mode';
  static const _defaultMode = 'system';

  static final ValueNotifier<String> themeNameNotifier =
      ValueNotifier<String>(Themes.defaultPalette);
  static final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  static List<DropdownMenuItem<String>> themesList = Themes.themesList;

  static ThemeData get lightTheme =>
      Themes.lightFromName(themeNameNotifier.value);
  static ThemeData get darkTheme =>
      Themes.darkFromName(themeNameNotifier.value);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    themeNameNotifier.value =
        prefs.getString(_themePaletteKey) ?? Themes.defaultPalette;
    themeModeNotifier.value =
        _themeModeFromName(prefs.getString(_themeModeKey) ?? _defaultMode);
  }

  static Future<void> changeTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePaletteKey, themeName);
    themeNameNotifier.value = themeName;
  }

  static Future<void> changeThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _themeModeName(mode));
    themeModeNotifier.value = mode;
  }

  static String _themeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  static ThemeMode _themeModeFromName(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
