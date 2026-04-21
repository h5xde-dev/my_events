import 'package:flutter/material.dart';
import 'package:my_events/app/shared/widgets/widgets.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppStubPage(
      title: 'События',
      description: 'Каталог событий скоро вернется в обновленном виде.',
      icon: Icons.grid_view_rounded,
    );
  }
}
