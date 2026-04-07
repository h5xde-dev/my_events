import 'package:flutter/material.dart';
import 'package:my_events/data_static/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Customisation {
  static const _themeKey = 'theme';
  static final ValueNotifier<ThemeData> themeNotifier =
      ValueNotifier<ThemeData>(Themes.pink());

  static List<DropdownMenuItem<String>> themesList = Themes.themesList;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    themeNotifier.value = Themes.fromName(prefs.getString(_themeKey));
  }

  static Future<void> changeTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeName);
    themeNotifier.value = Themes.fromName(themeName);
  }
}