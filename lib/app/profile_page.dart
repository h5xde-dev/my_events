import 'package:flutter/material.dart';
import 'package:my_events/app/edit_profile_page.dart';
import 'package:my_events/app/search_page.dart';
import 'package:my_events/app/settings_page.dart';
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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
              final bio =
                  (profile['bio'] as String?) ?? 'Добавьте информацию о себе';
              final favoritesCount =
                  (profile['favoritesCount'] as num?)?.toInt() ?? 0;
              final eventsCreatedCount =
                  (profile['eventsCreatedCount'] as num?)?.toInt() ?? 0;
              final streakLength =
                  (profile['streakLength'] as num?)?.toInt() ?? 0;
              final lastActivityDayKey =
                  profile['lastActivityDayKey'] as String?;
              final earnedBadgesRaw = profile['earnedBadges'];
              final earnedBadges = (earnedBadgesRaw is List)
                  ? earnedBadgesRaw.whereType<String>().toList(growable: false)
                  : <String>[];
              final retentionLine =
                  'D7: ${(RetentionMetricsTargets.d7Retention * 100).toStringAsFixed(0)}% | '
                  'D30: ${(RetentionMetricsTargets.d30Retention * 100).toStringAsFixed(0)}% | '
                  'WAU/MAU: ${(RetentionMetricsTargets.wauMau * 100).toStringAsFixed(0)}% | '
                  '2+ сессии/нед: ${(RetentionMetricsTargets.sessions2plusPerWeek * 100).toStringAsFixed(0)}%';

              const badgeTitles = <String, String>{
                'first_favorite': 'Первый лайк',
                'five_favorites': '5 избранных',
                'ten_favorites': '10 избранных',
                'twenty_favorites': '20 избранных',
                'first_event_created': 'Первое событие',
                'streak_3': 'Серия 3 дня',
                'streak_7': 'Серия 7 дней',
              };

              final nextStreakTarget = streakLength < 3
                  ? 3
                  : streakLength < 7
                      ? 7
                      : null;
              final nextStreakLeft = nextStreakTarget == null
                  ? 0
                  : (nextStreakTarget - streakLength);

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppScreenHeader(
                        title: 'Профиль',
                        trailing: AppIconActionButton(
                          icon: Icons.search,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const SearchPage()),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        tileColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        title: Text(
                          name,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          bio,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          color: Theme.of(context).colorScheme.primary,
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
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Прогресс и бейджи',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Серия: $streakLength дней • Избранное: $favoritesCount • Создано: $eventsCreatedCount',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            if (nextStreakTarget != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  'До серии $nextStreakTarget дней осталось $nextStreakLeft',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            if (nextStreakTarget == null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  'Серия прокачана. Продолжайте!',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            if (lastActivityDayKey != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  'Последняя активность: $lastActivityDayKey',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withValues(alpha: 0.9),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 10),
                            if (earnedBadges.isEmpty)
                              Text(
                                'Нажмите «Возможно пойду» или добавьте событие в избранное — и откроете первые бейджи.',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withValues(alpha: 0.9),
                                  fontSize: 12,
                                ),
                              )
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: earnedBadges
                                    .take(8)
                                    .map(
                                      (id) => Chip(
                                        label: Text(
                                          badgeTitles[id] ?? id,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.12),
                                      ),
                                    )
                                    .toList(growable: false),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Цели удержания (метрики продукта)',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              retentionLine,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SettingsPage(auth: auth),
                          ),
                        ),
                        icon: const Icon(Icons.settings),
                        label: const Text('Настройки'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
