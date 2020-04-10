import 'package:flutter/material.dart';
import 'package:my_events/app/landing_page.dart';
import 'package:my_events/services/auth.dart';
import 'package:my_events/app/map_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget
{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.white,
      
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/map': (context) => MapPage(auth: Auth()),
      },
      title: 'MyEvents',
      theme:ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: LandingPage(
        auth: Auth(),
      ),
    );
  }
}