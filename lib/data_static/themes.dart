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
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.pink,
        primary: Colors.pink,
        secondary: Colors.purple,
        surface: Colors.white,
      ),
    );
  }

  static ThemeData purple() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.purple,
        primary: Colors.purple,
        secondary: Colors.purpleAccent,
        surface: Colors.white,
      ),
    );
  }
}