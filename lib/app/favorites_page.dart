import 'package:flutter/material.dart';
import 'package:my_events/app/shared/widgets/widgets.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppStubPage(
      title: 'Избранное',
      description: 'Раздел избранного будет доступен в следующем обновлении.',
      icon: Icons.favorite_rounded,
    );
  }
}
