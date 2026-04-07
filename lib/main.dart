import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_events/app/landing_page.dart';
import 'package:my_events/services/auth.dart';
import 'package:my_events/services/analytics_service.dart';
import 'package:my_events/services/customisation.dart';
import 'package:my_events/services/notifications_service.dart';
import 'package:my_events/state/events_controller.dart';
import 'package:my_events/state/events_scope.dart';
import 'package:my_events/state/favorites_controller.dart';
import 'package:my_events/state/favorites_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Customisation.init();
  await NotificationsService.init();
  await NotificationsService.registerPushToken();
  await AnalyticsService.logAppOpen();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FavoritesController _favoritesController = FavoritesController();
  final EventsController _eventsController = EventsController();

  @override
  void initState() {
    super.initState();
    _eventsController.start();
  }

  @override
  void dispose() {
    _favoritesController.dispose();
    _eventsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EventsScope(
      controller: _eventsController,
      child: FavoritesScope(
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
      ),
    );
  }
}