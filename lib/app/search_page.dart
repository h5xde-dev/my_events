import 'package:flutter/material.dart';
import 'package:my_events/app/event_details_page.dart';
import 'package:my_events/common_widgets/animated_background.dart';
import 'package:my_events/data/event_repository.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final _repo = const EventRepository();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = _repo.getPopularEvents();
    final filtered = all
        .where((e) =>
            e.title.toLowerCase().contains(_query.toLowerCase()) ||
            e.description.toLowerCase().contains(_query.toLowerCase()))
        .toList();

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
                  onChanged: (value) => setState(() => _query = value),
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
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
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
                          child: Image.asset(
                            event.imageAsset,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
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

