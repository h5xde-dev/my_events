import 'package:flutter/material.dart';
import 'package:my_events/app/landing_page.dart';
import 'package:my_events/services/auth.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget
{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.black,
      
      debugShowCheckedModeBanner: false,
      title: 'MyEvents',
      theme:ThemeData(
        backgroundColor: Colors.white,
        primaryColor: Colors.pink,
        primaryColorDark: Colors.purple,
        accentColor: Colors.purple,
        primarySwatch: Colors.red,
        textSelectionColor: Colors.black,
        secondaryHeaderColor:  Colors.pink,
      ),
      home: LandingPage(auth:Auth())
    );
  }
}