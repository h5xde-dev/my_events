import 'package:flutter/material.dart';
import 'package:my_events/app/shared/widgets/widgets.dart';
import 'package:my_events/services/auth.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.auth});

  final AuthBase auth;

  @override
  Widget build(BuildContext context) {
    return const AppStubPage(
      title: 'Настройки',
      description:
          'Параметры приложения временно отключены в рамках упрощения.',
      icon: Icons.settings_rounded,
    );
  }
}
