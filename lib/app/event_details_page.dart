import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:my_events/app/chat_page.dart';
import 'package:my_events/app/edit_event_page.dart';
import 'package:my_events/models/event.dart';
import 'package:my_events/services/analytics_service.dart';
import 'package:my_events/services/notifications_service.dart';
import 'package:my_events/services/auth.dart';
import 'package:my_events/services/feature_flags_service.dart';
import 'package:my_events/state/events_controller.dart';
import 'package:my_events/state/events_scope.dart';
import 'package:my_events/state/favorites_scope.dart';

class EventDetailsPage extends StatelessWidget {
  const EventDetailsPage({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final favorites = FavoritesScope.of(context);
    final isFav = favorites.isFavorite(event.id);
    final auth = Auth();
    final eventsController = EventsScope.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _eventImage(event.imageAsset),
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
                            if (FeatureFlagsService.socialProofEnabled)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.people, color: Colors.white70),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _friendsLabel(event.friendsGoing),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            FilledButton(
                              onPressed: () async {
                                await NotificationsService
                                    .scheduleLocalReminder(
                                  id: event.id.hashCode,
                                  title: 'Напоминание о событии',
                                  body: 'Не забудьте: ${event.title}',
                                );
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Напоминание установлено'),
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
                            if (FeatureFlagsService.socialProofEnabled)
                              OutlinedButton.icon(
                                onPressed: () {
                                  AnalyticsService.logFriendProofOpened(
                                    eventId: event.id,
                                  );
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ChatPage(event: event),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.chat_bubble_outline),
                                label: const Text('Мини-сквад'),
                              ),
                            if (FeatureFlagsService.socialProofEnabled)
                              const SizedBox(height: 8),
                            if (FeatureFlagsService.postEventFlowEnabled)
                              OutlinedButton.icon(
                                onPressed: () => _openPostEventFlow(
                                  context: context,
                                  sourceEvent: event,
                                  eventsController: eventsController,
                                ),
                                icon: const Icon(Icons.auto_awesome),
                                label: const Text('Что дальше'),
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

  Widget _eventImage(String path) {
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

  void _openPostEventFlow({
    required BuildContext context,
    required Event sourceEvent,
    required EventsController eventsController,
  }) {
    final notesController = TextEditingController();
    final next = eventsController
        .smartWeekRecommendations(maxItems: 3)
        .where((item) => item.event.id != sourceEvent.id)
        .toList();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Что дальше',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text('Сохрани заметку и выбери следующее событие.'),
              const SizedBox(height: 10),
              TextField(
                controller: notesController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'С кем познакомился(лась), что полезного узнал(а)?',
                ),
              ),
              const SizedBox(height: 12),
              ...next.map((item) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.event.title),
                  subtitle:
                      Text(item.reason, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    AnalyticsService.logNextEventTapped(
                      sourceEventId: sourceEvent.id,
                      targetEventId: item.event.id,
                    );
                    Navigator.of(sheetContext).push(
                      MaterialPageRoute(
                        builder: (_) => EventDetailsPage(event: item.event),
                      ),
                    );
                  },
                );
              }),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () async {
                  await AnalyticsService.logPostEventCompleted(
                    eventId: sourceEvent.id,
                    nextOptions: next.length,
                  );
                  if (!sheetContext.mounted) return;
                  Navigator.of(sheetContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Отлично! Сохранили твой прогресс.')),
                  );
                },
                child: const Text('Готово'),
              ),
            ],
          ),
        );
      },
    ).whenComplete(notesController.dispose);
  }
}
