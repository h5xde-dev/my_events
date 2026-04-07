import 'package:flutter/material.dart';
import 'package:my_events/app/events_page.dart';
import 'package:my_events/app/favorites_page.dart';
import 'package:my_events/app/main_page.dart';
import 'package:my_events/app/map_page.dart';
import 'package:my_events/app/profile_page.dart';
import 'package:my_events/app/search_page.dart';
import 'package:my_events/app/settings_page.dart';
import 'package:my_events/services/auth.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key, required this.auth});

  final AuthBase auth;

  @override
  _NavigationMenuState createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const MainPage(),
      const EventsPage(),
      const FavoritesPage(),
      const SearchPage(),
      MapPage(auth: widget.auth),
      const ProfilePage(),
      SettingsPage(auth: widget.auth),
    ];

    return Scaffold(
      body: Center(
        child: pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: .1),
            ),
          ],
        ),
        child: SafeArea(
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'Главная'),
              NavigationDestination(icon: Icon(Icons.grid_view), label: 'События'),
              NavigationDestination(icon: Icon(Icons.favorite), label: 'Избранное'),
              NavigationDestination(icon: Icon(Icons.search), label: 'Поиск'),
              NavigationDestination(icon: Icon(Icons.map), label: 'Карта'),
              NavigationDestination(
                icon: Icon(Icons.account_circle),
                label: 'Профиль',
              ),
              NavigationDestination(icon: Icon(Icons.settings), label: 'Настройки'),
            ],
          ),
        ),
      ),
    );
  }
}