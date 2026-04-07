import 'package:flutter/material.dart';
import 'package:my_events/app/event_details_page.dart';
import 'package:my_events/common_widgets/animated_background.dart';
import 'package:my_events/data/event_repository.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final events = const EventRepository().getPopularEvents();

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
                Expanded(
                  child: GridView.builder(
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
                              Image.asset(event.imageAsset, fit: BoxFit.cover),
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

