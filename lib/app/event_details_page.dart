import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:my_events/app/edit_event_page.dart';
import 'package:my_events/models/event.dart';
import 'package:my_events/services/notifications_service.dart';
import 'package:my_events/services/auth.dart';
import 'package:my_events/data/user_stats_repository.dart';
import 'package:my_events/state/favorites_scope.dart';

class EventDetailsPage extends StatelessWidget {
  const EventDetailsPage({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final favorites = FavoritesScope.of(context);
    final isFav = favorites.isFavorite(event.id);
    final auth = Auth();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _eventImage(event),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.black.withValues(alpha: 0.25),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.white,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => favorites.toggle(event.id),
                        icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border),
                        color: Colors.white,
                      ),
                      FutureBuilder<User?>(
                        future: auth.currentUser(),
                        builder: (context, snapshot) {
                          final canEdit = event.createdBy != null &&
                              snapshot.data?.uid == event.createdBy;
                          if (!canEdit) return const SizedBox.shrink();
                          return IconButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EditEventPage(event: event),
                              ),
                            ),
                            icon: const Icon(Icons.edit),
                            color: Colors.white,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontFamily: "SF-Pro-Text-Regular",
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              event.description,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontFamily: "SF-Pro-Text-Regular",
                              ),
                            ),
                            const SizedBox(height: 14),
                            if (event.place.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  'Место: ${event.place}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            FilledButton(
                              onPressed: () async {
                                final user = await auth.currentUser();
                                if (user != null) {
                                  await const UserStatsRepository().onMaybeGo(
                                    userId: user.uid,
                                    at: DateTime.now(),
                                  );
                                }
                                await NotificationsService
                                    .scheduleLocalReminder(
                                  id: event.id.hashCode,
                                  title: 'Напоминание о событии',
                                  body: 'Не забудьте: ${event.title}',
                                );
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Напоминание установлено и прогресс обновлен'),
                                  ),
                                );
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                              ),
                              child: const Text('Возможно пойду'),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _friendsLabel(event.friendsGoing),
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _eventImage(Event item) {
    final path = (item.imageUrl?.trim().isNotEmpty ?? false)
        ? item.imageUrl!.trim()
        : item.imageAsset;
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image.asset('images/image_01.png', fit: BoxFit.cover),
      );
    }
    return Image.asset(path, fit: BoxFit.cover);
  }

  String _friendsLabel(int count) {
    if (count <= 0) return 'Пока никто из друзей не отметил участие';
    if (count == 1) return '1 друг уже планирует идти';
    return '$count друзей уже планируют идти';
  }
}
