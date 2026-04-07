import 'package:flutter/material.dart';
import 'package:my_events/app/event_details_page.dart';
import 'package:my_events/common_widgets/animated_background.dart';
import 'package:my_events/models/event.dart';
import 'package:my_events/state/events_scope.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final ScrollController _scrollController = ScrollController();
  String _category = 'Все';
  String _dateFilter = 'Все';
  static const _categories = ['Все', 'Общее', 'Город', 'Маркет', 'Нетворкинг', 'Лаунж'];
  static const _dateFilters = ['Все', 'Сегодня', 'Эта неделя'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsController = EventsScope.of(context);

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
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 42,
                    fontFamily: "Calibre-Semibold",
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      DropdownButton<String>(
                        value: _category,
                        items: _categories
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => _category = v ?? 'Все'),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: _dateFilter,
                        items: _dateFilters
                            .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                            .toList(),
                        onChanged: (v) => setState(() => _dateFilter = v ?? 'Все'),
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
                      if (eventsController.isLoading && events.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (eventsController.error != null && events.isEmpty) {
                        return Center(
                          child: Text(
                            'Ошибка загрузки: ${eventsController.error}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }
                      if (events.isEmpty) {
                        return Center(
                          child: Text(
                            'Событий пока нет. Создайте первое событие.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        );
                      }
                      return GridView.builder(
                        controller: _scrollController,
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
                                builder: (_) => EventDetailsPage(event: event),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  _eventImage(event),
                                  Container(
                                    color: Colors.black.withValues(alpha: 0.25),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        event.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
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
                      return const Padding(
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: Text(
                          'Все события загружены',
                          style: TextStyle(color: Colors.white70),
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

