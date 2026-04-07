import 'package:flutter/material.dart';
import 'package:my_events/common_widgets/animated_background.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Профиль',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 42,
                    fontFamily: "Calibre-Semibold",
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Экран в разработке: тут будут настройки профиля, история посещений и персональные рекомендации.',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

