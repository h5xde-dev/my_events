import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
                gap: 8,
                activeColor: Theme.of(context).colorScheme.surface,
                iconSize: 24,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                duration: const Duration(milliseconds: 800),
                tabBackgroundColor: Theme.of(context).colorScheme.onSurface,
                tabs: [
                  GButton(
                    icon: Icons.home,
                    text: 'Главная',
                  ),
                  GButton(
                    icon: Icons.grid_view,
                    text: 'События',
                  ),
                  GButton(
                    icon: Icons.favorite,
                    text: 'Избранное',
                  ),
                  GButton(
                    icon: Icons.search,
                    text: 'Поиск',
                  ),
                  GButton(
                    icon: Icons.map,
                    text: 'Карта',
                  ),
                  GButton(
                    icon: Icons.account_circle,
                    text: 'Профиль',
                  ),
                  GButton(
                    icon: Icons.settings,
                    text: 'Настройки',
                  ),
                ],
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                }),
          ),
        ),
      ),
    );
  }
}