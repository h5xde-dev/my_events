import 'package:flutter/material.dart';

class Themes {

  List<Map> data = [
    {
      'name': 'purple',
      'background': Colors.white,
      'font' : Colors.black,
      'gradientStart': Colors.purple[200],
      'gradientEnd': Colors.purple,
      'waveColor': Colors.deepPurple.withAlpha(60),
    },
    {
      'name': 'pink',
      'background': Colors.white,
      'font' : Colors.black,
      'gradientStart': Colors.pink[200],
      'gradientEnd': Colors.pink,
      'waveColor': Colors.pink.withAlpha(60),
    }
  ];
}