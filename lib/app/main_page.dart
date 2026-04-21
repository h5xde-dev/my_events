import 'package:my_events/app/create_event_page.dart';
import 'package:my_events/app/events_page.dart';
import 'package:my_events/app/favorites_page.dart';
import 'package:my_events/app/search_page.dart';
import 'package:flutter/material.dart';
import 'package:my_events/app/main/widgets/widgets.dart';
import 'package:my_events/app/shared/widgets/widgets.dart';
import 'package:my_events/data/event_repository.dart';
import 'package:my_events/models/event.dart';
import 'package:my_events/state/events_scope.dart';
import 'package:my_events/state/favorites_scope.dart';
import 'package:my_events/services/auth.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Event> events = const [];
  late final PageController _controller;
  double currentPage = 0;

  List<Event> favoriteEvents = const [];
  late final PageController _favoritesController;
  double favoriteCurrentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0)
      ..addListener(() {
        final page = _controller.page;
        if (page == null) return;
        setState(() => currentPage = page);
      });

    _favoritesController = PageController(initialPage: 0)
      ..addListener(() {
        final page = _favoritesController.page;
        if (page == null) return;
        setState(() => favoriteCurrentPage = page);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _favoritesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsController = EventsScope.of(context);
    final favoritesController = FavoritesScope.of(context);
    final auth = Auth();
    final repo = const EventRepository();
    final sourceEvents = eventsController.events;
    if (sourceEvents.isNotEmpty && events != sourceEvents) {
      events = sourceEvents;
      if (_controller.hasClients) {
        final targetPage = (events.length - 1).clamp(0, events.length - 1);
        _controller.jumpToPage(targetPage);
      }
      currentPage = (events.length - 1).toDouble();
    }

    final sourceFavoriteEvents = sourceEvents
        .where((e) => favoritesController.isFavorite(e.id))
        .toList();
    if (sourceFavoriteEvents.isNotEmpty &&
        favoriteEvents != sourceFavoriteEvents) {
      favoriteEvents = sourceFavoriteEvents;
      if (_favoritesController.hasClients) {
        final targetPage =
            (favoriteEvents.length - 1).clamp(0, favoriteEvents.length - 1);
        _favoritesController.jumpToPage(targetPage);
      }
      favoriteCurrentPage = (favoriteEvents.length - 1).toDouble();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            if (eventsController.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: LinearProgressIndicator(),
              ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 12.0, right: 12.0, top: 30.0, bottom: 8.0),
              child: AppScreenHeader(
                title: 'Главная',
                trailing: AppIconActionButton(
                  icon: Icons.search,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SearchPage(),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: const AppSectionTitle(title: 'Популярные'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: FutureBuilder<User?>(
                future: auth.currentUser(),
                builder: (context, userSnapshot) {
                  final user = userSnapshot.data;
                  if (user == null) return const SizedBox.shrink();
                  return StreamBuilder<Map<String, dynamic>?>(
                    stream: repo.watchProfile(user.uid),
                    builder: (context, profileSnapshot) {
                      final profile = profileSnapshot.data ?? const {};
                      final streakLength =
                          (profile['streakLength'] as num?)?.toInt() ?? 0;
                      final nextStreakTarget = streakLength < 3
                          ? 3
                          : streakLength < 7
                              ? 7
                              : null;
                      final nextLeft = nextStreakTarget == null
                          ? 0
                          : nextStreakTarget - streakLength;

                      final message = nextStreakTarget == null
                          ? 'Серия прокачана. Продолжайте!'
                          : 'До серии $nextStreakTarget дней осталось $nextLeft';

                      return Text(
                        message,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Row(
                children: <Widget>[
                  const AppLabelChip(label: 'Рекомендуем'),
                  const SizedBox(
                    width: 15.0,
                  ),
                  Text("25+ Событий",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EventsPage(),
                      ),
                    ),
                    icon: const Icon(Icons.grid_view),
                    label: const Text('Каталог'),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CreateEventPage(),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Создать'),
                  ),
                ],
              ),
            ),
            Stack(
              children: <Widget>[
                if (events.isNotEmpty) ...[
                  EventCard(
                    currentPage: currentPage,
                    events: events,
                  ),
                  Positioned.fill(
                    child: PageView.builder(
                      itemCount: events.length,
                      controller: _controller,
                      reverse: true,
                      itemBuilder: (context, index) {
                        return Container();
                      },
                    ),
                  ),
                ] else
                  SizedBox(
                    height: 320,
                    child: Center(
                      child: eventsController.error == null
                          ? const CircularProgressIndicator()
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                'Не удалось загрузить ленту. Проверьте интернет и попробуйте снова.',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: AppSectionTitle(
                title: 'Избранные',
                action: AppIconActionButton(
                  icon: Icons.favorite,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const FavoritesPage(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (favoriteEvents.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Пока нет избранных. Нажмите на сердечко на карточке события.',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.72),
                    fontSize: 14,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Stack(
                  children: <Widget>[
                    EventCard(
                      currentPage: favoriteCurrentPage,
                      events: favoriteEvents,
                    ),
                    Positioned.fill(
                      child: PageView.builder(
                        itemCount: favoriteEvents.length,
                        controller: _favoritesController,
                        reverse: true,
                        itemBuilder: (context, index) {
                          return Container();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
