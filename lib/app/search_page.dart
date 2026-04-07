import 'package:flutter/material.dart';
import 'package:my_events/app/event_details_page.dart';
import 'package:my_events/common_widgets/animated_background.dart';
import 'package:my_events/models/event.dart';
import 'package:my_events/services/analytics_service.dart';
import 'package:my_events/state/events_scope.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  String _category = 'Все';
  String _dateFilter = 'Все';
  static const _categories = ['Все', 'Общее', 'Город', 'Маркет', 'Нетворкинг', 'Лаунж'];
  static const _dateFilters = ['Все', 'Сегодня', 'Эта неделя'];

  @override
  void dispose() {
    _controller.dispose();
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
              children: [
                TextField(
                  controller: _controller,
                  onChanged: (value) {
                    setState(() => _query = value);
                    if (value.trim().length >= 2) {
                      AnalyticsService.logSearchUsed(query: value.trim());
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Поиск событий',
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.85),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
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
                const SizedBox(height: 16),
                Expanded(
                  child: AnimatedBuilder(
                    animation: eventsController,
                    builder: (context, _) {
                      final all = eventsController.events;
                      final filtered = _applyFilters(all)
                          .where((e) =>
                              e.title
                                  .toLowerCase()
                                  .contains(_query.toLowerCase()) ||
                              e.description
                                  .toLowerCase()
                                  .contains(_query.toLowerCase()))
                          .toList();
                      if (eventsController.isLoading && all.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (filtered.isEmpty) {
                        return Center(
                          child: Text(
                            'Ничего не найдено. Попробуйте другой запрос или фильтр.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final event = filtered[i];
                          return ListTile(
                            tileColor: Colors.white.withValues(alpha: 0.16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _eventImage(event),
                            ),
                            title: Text(
                              event.title,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              event.description,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EventDetailsPage(event: event),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
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
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image.asset('images/image_01.png', width: 56, height: 56),
      );
    }
    return Image.asset(event.imageAsset, width: 56, height: 56, fit: BoxFit.cover);
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
}

