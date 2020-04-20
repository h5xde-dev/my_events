import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:my_events/app/main_page.dart';
import 'package:my_events/app/map_page.dart';
import 'package:my_events/app/settings_page.dart';
import 'package:my_events/services/auth.dart';

class NavigationMenu extends StatefulWidget {
  NavigationMenu({
    @required this.auth,
  });

  final AuthBase auth;

  @override
  _NavigationMenuState createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  List<Widget> _widgetOptions = <Widget>[
    MainPage(auth: Auth()),
    Text(
      'Index 3: Profile',
      style: optionStyle,
    ),
    MapPage(auth: Auth()),
    SettingsPage(auth: Auth()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Theme.of(context).cursorColor, boxShadow: [
          BoxShadow(blurRadius: 20, color: Theme.of(context).primaryColor.withOpacity(.1))
        ]),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
                gap: 8,
                activeColor: Theme.of(context).backgroundColor,
                iconSize: 24,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                duration: Duration(milliseconds: 800),
                tabBackgroundColor: Theme.of(context).backgroundColor,
                textStyle: TextStyle(
                  color: Theme.of(context).textSelectionColor
                ),
                tabs: [
                  GButton(
                    iconColor: Theme.of(context).backgroundColor,
                    iconActiveColor: Theme.of(context).primaryColor,
                    icon: Icons.home,
                    text: 'Главная',
                  ),
                  GButton(
                    iconColor: Theme.of(context).backgroundColor,
                    iconActiveColor: Theme.of(context).primaryColor,
                    icon: Icons.favorite,
                    text: 'Избранное',
                  ),
                  GButton(
                    iconColor: Theme.of(context).backgroundColor,
                    iconActiveColor: Theme.of(context).primaryColor,
                    icon: Icons.map,
                    text: 'Карта',
                  ),
                  GButton(
                    iconColor: Theme.of(context).backgroundColor,
                    iconActiveColor: Theme.of(context).primaryColor,
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