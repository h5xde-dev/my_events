import 'package:flutter/material.dart';
import 'package:my_events/app/edit_profile_page.dart';
import 'package:my_events/app/shared/widgets/widgets.dart';
import 'package:my_events/data/event_repository.dart';
import 'package:my_events/services/auth.dart';
import 'package:my_events/services/retention_metrics.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Auth();
    final repo = const EventRepository();

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<User?>(
          future: auth.currentUser(),
          builder: (context, userSnapshot) {
            final user = userSnapshot.data;
            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return StreamBuilder<Map<String, dynamic>?>(
              stream: repo.watchProfile(user.uid),
              builder: (context, profileSnapshot) {
                final profile = profileSnapshot.data ?? const {};
                final name = (profile['name'] as String?) ?? 'Пользователь';
                final bio = (profile['bio'] as String?) ?? 'Добавьте информацию о себе';
                final retentionLine =
                    'D7: ${(RetentionMetricsTargets.d7Retention * 100).toStringAsFixed(0)}% | '
                    'D30: ${(RetentionMetricsTargets.d30Retention * 100).toStringAsFixed(0)}% | '
                    'WAU/MAU: ${(RetentionMetricsTargets.wauMau * 100).toStringAsFixed(0)}% | '
                    '2+ сессии/нед: ${(RetentionMetricsTargets.sessions2plusPerWeek * 100).toStringAsFixed(0)}%';

                return SafeArea(
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
                        ListTile(
                          tileColor: Colors.white.withValues(alpha: 0.14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            bio,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            color: Colors.white,
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EditProfilePage(
                                  initialName: name,
                                  initialBio: bio,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Цели удержания',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                retentionLine,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

