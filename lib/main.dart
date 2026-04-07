import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_events/app/landing_page.dart';
import 'package:my_events/services/auth.dart';
import 'package:my_events/services/customisation.dart';
import 'package:my_events/state/favorites_controller.dart';
import 'package:my_events/state/favorites_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Customisation.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FavoritesController _favoritesController = FavoritesController();

  @override
  void dispose() {
    _favoritesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FavoritesScope(
      controller: _favoritesController,
      child: ValueListenableBuilder<ThemeData>(
        valueListenable: Customisation.themeNotifier,
        builder: (context, theme, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'MyEvents',
            theme: theme,
            home: LandingPage(auth: Auth()),
          );
        },
      ),
    );
  }
}