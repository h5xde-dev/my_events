import 'package:flutter/material.dart';

class Themes {
  static List<DropdownMenuItem> themesList = [
    DropdownMenuItem(
      child:Text('Pink'),
      value: 'pink',
    ),
    DropdownMenuItem(
      child:Text('Purple'),
      value: 'purple',
    )
  ];

  static ThemeData pink() {
    return ThemeData(
      backgroundColor: Colors.white,
      primaryColor: Colors.pink,
      primaryColorDark: Colors.purple,
      accentColor: Colors.purple,
      primarySwatch: Colors.red,
      textSelectionColor: Colors.black,
      secondaryHeaderColor:  Colors.pink,
    );
  }

  static ThemeData purple() {
    return ThemeData(
      backgroundColor: Colors.white,
      primaryColor: Colors.purple,
      primaryColorDark: Colors.purple,
      accentColor: Colors.purple,
      primarySwatch: Colors.red,
      textSelectionColor: Colors.black,
      secondaryHeaderColor:  Colors.purple,
    );
  }
}