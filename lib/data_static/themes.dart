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
    ),
    DropdownMenuItem(
      child:Text('Red'),
      value: 'red',
    ),
    DropdownMenuItem(
      child:Text('DarkMilk'),
      value: 'dark',
    )
  ];

  static ThemeData pink() {
    return ThemeData(
      backgroundColor: Colors.white,
      primaryColor: Colors.pink,
      primaryColorDark: Colors.purple,
      accentColor: Colors.purple,
      primarySwatch: Colors.red,
      cursorColor: Colors.black,
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
      cursorColor: Colors.black,
      textSelectionColor: Colors.black,
      secondaryHeaderColor:  Colors.purple,
    );
  }

  static ThemeData red() {
    return ThemeData(
      backgroundColor: Colors.white,
      primaryColor: Colors.red,
      primaryColorDark: Colors.red,
      accentColor: Colors.red,
      primarySwatch: Colors.red,
      cursorColor: Colors.black,
      textSelectionColor: Colors.black,
      secondaryHeaderColor:  Colors.red,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      backgroundColor: Colors.black,
      primaryColor: Colors.white,
      primaryColorDark: Colors.black,
      accentColor: Colors.white,
      primarySwatch: Colors.pink,
      cursorColor: Colors.white,
      textSelectionColor: Colors.white,
      secondaryHeaderColor:  Colors.white,
    );
  }
}