import 'package:flutter/material.dart';
import 'package:my_events/app/shared/widgets/sections/app_screen_header.dart';

class AppStubPage extends StatelessWidget {
  const AppStubPage({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppScreenHeader(title: title),
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    Icon(icon, size: 56, color: scheme.primary),
                    const SizedBox(height: 12),
                    Text(
                      'Раздел в разработке',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
