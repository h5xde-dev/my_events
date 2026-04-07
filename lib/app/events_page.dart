import 'package:flutter/material.dart';
import 'package:my_events/app/event_details_page.dart';
import 'package:my_events/app/events/widgets/widgets.dart';
import 'package:my_events/app/shared/widgets/widgets.dart';
import 'package:my_events/data/chat_repository.dart';
import 'package:my_events/models/event.dart';
import 'package:my_events/services/analytics_service.dart';
import 'package:my_events/services/auth.dart';
import 'package:my_events/services/feature_flags_service.dart';
import 'package:my_events/state/events_controller.dart';
import 'package:my_events/state/events_scope.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final ScrollController _scrollController = ScrollController();
  final _chatRepository = const ChatRepository();
  final _auth = Auth();
  User? _user;
  String _category = 'Все';
  String _dateFilter = 'Все';
  bool _slotAnalyticsSent = false;
  static const _categories = [
    'Все',
    'Общее',
    'Город',
    'Маркет',
    'Нетворкинг',
    'Лаунж'
  ];
  static const _dateFilters = ['Все', 'Сегодня', 'Эта неделя'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _bindUser();
  }

  Future<void> _bindUser() async {
    final user = await _auth.currentUser();
    if (!mounted) return;
    setState(() => _user = user);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsController = EventsScope.of(context);
    final scheme = Theme.of(context).colorScheme;

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
                  'Все события',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: scheme.onSurface),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      DropdownButton<String>(
                        value: _category,
                        items: _categories
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _category = v ?? 'Все'),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: _dateFilter,
                        items: _dateFilters
                            .map((f) =>
                                DropdownMenuItem(value: f, child: Text(f)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _dateFilter = v ?? 'Все'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: AnimatedBuilder(
                    animation: eventsController,
                    builder: (context, _) {
                      final events = _applyFilters(eventsController.events);
                      final List<EventSlotRecommendation> betweenClasses =
                          FeatureFlagsService.betweenClassesEnabled
                              ? eventsController.betweenClassesRecommendations()
                              : const <EventSlotRecommendation>[];
                      final List<EventSlotRecommendation> smartWeek = FeatureFlagsService.smartWeekEnabled
                          ? eventsController.smartWeekRecommendations()
                          : const <EventSlotRecommendation>[];
                      if (!_slotAnalyticsSent &&
                          (betweenClasses.isNotEmpty || smartWeek.isNotEmpty)) {
                        _slotAnalyticsSent = true;
                        AnalyticsService.logSlotViewed(
                          slotType: 'between_classes',
                          items: betweenClasses.length,
                        );
                        AnalyticsService.logSlotViewed(
                          slotType: 'smart_week',
                          items: smartWeek.length,
                        );
                      }
                      if (eventsController.isLoading && events.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (eventsController.error != null && events.isEmpty) {
                        return Center(
                          child: Text(
                            'Ошибка загрузки: ${eventsController.error}',
                            style: TextStyle(color: scheme.onSurface),
                          ),
                        );
                      }
                      if (events.isEmpty) {
                        return Center(
                          child: Text(
                            'Событий пока нет. Создайте первое событие.',
                            style: TextStyle(
                              color: scheme.onSurface.withValues(alpha: 0.9),
                            ),
                          ),
                        );
                      }
                      return ListView(
                        controller: _scrollController,
                        children: [
                          if (betweenClasses.isNotEmpty)
                            EventSlotStrip(
                              title: 'Окна между парами',
                              items: betweenClasses,
                            ),
                          if (smartWeek.isNotEmpty)
                            EventSlotStrip(
                              title: 'Умная неделя',
                              items: smartWeek.take(5).toList(),
                            ),
                          const SizedBox(height: 8),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              final event = events[index];
                              return GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EventDetailsPage(event: event),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      _eventImage(event),
                                      Container(
                                        color:
                                            scheme.scrim.withValues(alpha: 0.2),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(
                                            event.title,
                                            style: TextStyle(
                                              color: scheme.onPrimaryContainer,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (_user != null)
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: UnreadBadge(
                                            eventId: event.id,
                                            userId: _user!.uid,
                                            chatRepository: _chatRepository,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
                AnimatedBuilder(
                  animation: eventsController,
                  builder: (context, _) {
                    final filtered = _applyFilters(eventsController.events);
                    if (eventsController.isLoadingMore) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (!eventsController.hasMore && filtered.isNotEmpty) {
                      return Padding(
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: Text(
                          'Все события загружены',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _eventImage(Event event) {
    final isNetwork = event.imageAsset.startsWith('http');
    if (isNetwork) {
      return Image.network(
        event.imageAsset,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image.asset('images/image_01.png', fit: BoxFit.cover),
      );
    }
    return Image.asset(event.imageAsset, fit: BoxFit.cover);
  }

  List<Event> _applyFilters(List<Event> source) {
    final now = DateTime.now();
    return source.where((event) {
      final matchCategory = _category == 'Все' || event.category == _category;
      final startsAt = event.startsAt;
      final matchDate = switch (_dateFilter) {
        'Сегодня' => startsAt != null &&
            startsAt.year == now.year &&
            startsAt.month == now.month &&
            startsAt.day == now.day,
        'Эта неделя' => startsAt != null &&
            startsAt.isAfter(now.subtract(const Duration(days: 1))) &&
            startsAt.isBefore(now.add(const Duration(days: 7))),
        _ => true,
      };
      return matchCategory && matchDate;
    }).toList();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent * 0.8;
    if (_scrollController.position.pixels < threshold) return;
    final controller = EventsScope.of(context);
    controller.loadMore();
  }
}
