import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:my_events/app/events_page.dart';
import 'package:my_events/app/favorites_page.dart';
import 'package:my_events/app/main_page.dart';
import 'package:my_events/app/map_page.dart';
import 'package:my_events/app/settings_page.dart';
import 'package:my_events/services/auth.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key, required this.auth});

  final AuthBase auth;

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late final TabController _tabController;
  static const int _centerTabIndex = 2;

  List<Color> get _accentColors => <Color>[
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.tertiary,
        Colors.pinkAccent,
        Colors.deepOrangeAccent
      ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.animation?.addListener(() {
      final index = _tabController.animation?.value.round() ?? 0;
      if (index != _selectedIndex && mounted) {
        setState(() => _selectedIndex = index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
            TabBar(
              controller: _tabController,
              indicatorPadding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  color: activeColor,
                  width: 4,
                ),
                insets: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              ),
              tabs: [
                _tabIcon(Icons.home, 0, 'Главная', unselectedColor, colors[0]),
                _tabIcon(Icons.map, 1, 'Карта', unselectedColor, colors[1]),
                _tabIcon(
                    Icons.favorite, 3, 'Избранное', unselectedColor, colors[2]),
                _tabIcon(
                    Icons.settings, 4, 'Настройки', unselectedColor, colors[3]),
              ],
            ),
            Positioned(
              top: -25,
              child: FloatingActionButton(
                heroTag: 'nav_fab',
                onPressed: () {},
                backgroundColor: colors[_centerTabIndex],
                foregroundColor: Colors.white,
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
        body: (context, controller) => TabBarView(
          controller: _tabController,
          dragStartBehavior: DragStartBehavior.down,
          physics: const BouncingScrollPhysics(),
          children: [
            const MainPage(),
            MapPage(auth: widget.auth),
            const FavoritesPage(),
            SettingsPage(auth: widget.auth)
          ],
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
    return SizedBox(
      height: 55,
      width: 40,
      child: Center(
        child: Icon(
          icon,
          semanticLabel: semantics,
          color: isSelected ? selectedColor : unselectedColor,
        ),
      ),
    );
  }
}
