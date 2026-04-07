import 'package:flutter/material.dart';
import 'package:my_events/common_widgets/animated_background.dart';
import 'package:my_events/data/event_repository.dart';
import 'package:my_events/state/favorites_scope.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = EventRepository();
    final all = repo.getPopularEvents();
    final favorites = FavoritesScope.of(context);

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedBuilder(
          animation: favorites,
          builder: (context, _) {
            final favEvents =
                all.where((e) => favorites.isFavorite(e.id)).toList();

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Избранные',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 42,
                        fontFamily: "Calibre-Semibold",
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (favEvents.isEmpty)
                      Text(
                        'Пока пусто. Поставь лайк на карточке события.',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          itemCount: favEvents.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final e = favEvents[i];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: ListTile(
                                tileColor: Colors.white.withValues(alpha: 0.14),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    e.imageAsset,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  e.title,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  e.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.75),
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.favorite),
                                  color: Colors.white,
                                  onPressed: () => favorites.toggle(e.id),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

