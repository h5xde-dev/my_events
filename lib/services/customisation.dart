import 'package:flutter/material.dart';
import 'package:my_events/data_static/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Customisation {

  static List <DropdownMenuItem>themesList = Themes.themesList;

  static Future<void> changeTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('theme', themeName);
  }

  static Future<ThemeData> getTheme() async {
    final prefs = await SharedPreferences.getInstance();

    switch (prefs.getString('theme')) {
      case 'pink':
        return Themes.pink();
        break;
      case 'purple':
        return Themes.purple();
        break;
      default:
        return Themes.pink();
    }
  }
}