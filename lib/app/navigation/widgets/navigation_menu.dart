import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:my_events/app/map_page.dart';
import 'package:my_events/app/shared/widgets/widgets.dart';
import 'package:my_events/services/auth.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key, required this.auth});

  final AuthBase auth;

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int _selectedIndex = 0;
  static const int _centerTabIndex = 2;

  List<Color> get _accentColors => <Color>[
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.tertiary,
        Colors.pinkAccent,
        Colors.deepOrangeAccent
      ];

  List<Widget> _pages() => [
        MapPage(auth: widget.auth),
        const AppStubPage(
          title: 'Поиск',
          description: 'Здесь будет поиск по событиям и фильтры.',
          icon: Icons.search,
        ),
        const AppStubPage(
          title: 'Избранное',
          description: 'Здесь появятся сохраненные вами события.',
          icon: Icons.favorite,
        ),
        const AppStubPage(
          title: 'Настройки',
          description: 'Раздел настроек скоро будет доступен.',
          icon: Icons.settings,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final colors = _accentColors;
    final activeColor = colors[_selectedIndex];
    final barColor = activeColor.computeLuminance() > 0.5
        ? Theme.of(context).colorScheme.inverseSurface
        : Theme.of(context).colorScheme.surface;
    final unselectedColor = barColor.computeLuminance() < 0.5
        ? Colors.white
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      body: BottomBar(
        clip: Clip.none,
        borderRadius: BorderRadius.circular(999),
        width: MediaQuery.of(context).size.width * 0.88,
        barAlignment: Alignment.bottomCenter,
        barColor: barColor,
        showIcon: true,
        hideOnScroll: true,
        offset: 12,
        start: _centerTabIndex.toDouble(),
        end: 0,
        iconHeight: 30,
        iconWidth: 30,
        icon: (width, height) => Icon(
          Icons.keyboard_arrow_up_rounded,
          color: unselectedColor,
          size: width,
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _tabIcon(Icons.map, 0, 'Карта', unselectedColor, colors[0]),
                _tabIcon(Icons.search, 1, 'Поиск', unselectedColor, colors[1]),
                _tabIcon(
                    Icons.favorite, 2, 'Избранное', unselectedColor, colors[2]),
                _tabIcon(
                    Icons.settings, 3, 'Настройки', unselectedColor, colors[3]),
              ],
            ),
            Positioned(
              top: -25,
              child: FloatingActionButton(
                heroTag: 'nav_fab',
                onPressed: () => setState(() => _selectedIndex = 0),
                backgroundColor: colors[_centerTabIndex],
                foregroundColor: Colors.white,
                child: const Icon(Icons.map),
              ),
            ),
          ],
        ),
        body: (context, controller) => IndexedStack(
          index: _selectedIndex,
          children: _pages(),
        ),
      ),
    );
  }

  Widget _tabIcon(
    IconData icon,
    int index,
    String semantics,
    Color unselectedColor,
    Color selectedColor,
  ) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: SizedBox(
        height: 55,
        width: 40,
        child: Center(
          child: Icon(
            icon,
            semanticLabel: semantics,
            color: isSelected ? selectedColor : unselectedColor,
          ),
        ),
      ),
    );
  }
}
