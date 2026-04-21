import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:my_events/app/event_details_page.dart';
import 'package:my_events/models/event.dart';
import 'package:my_events/services/analytics_service.dart';
import 'package:my_events/state/favorites_scope.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.currentPage,
    required this.events,
  });

  final double currentPage;
  final List<Event> events;
  final double padding = 20.0;
  final double verticalInset = 20.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    var cardAspectRatio = 12.0 / 16.0;
    var widgetAspectRatio = cardAspectRatio * 1.2;

    return AspectRatio(
      aspectRatio: widgetAspectRatio,
      child: LayoutBuilder(builder: (context, constraints) {
        var width = constraints.maxWidth;
        var height = constraints.maxHeight;

        var safeWidth = width - 2 * padding;
        var safeHeight = height - 2 * padding;

        var heightOfPrimaryCard = safeHeight;
        var widthOfPrimaryCard = heightOfPrimaryCard * cardAspectRatio;

        var primaryCardLeft = safeWidth - widthOfPrimaryCard;
        var horizontalInset = primaryCardLeft / 2;

        final cardList = <Widget>[];

        for (var i = 0; i < events.length; i++) {
          var delta = i - currentPage;
          bool isOnRight = delta > 0;

          var start = padding +
              max(
                  primaryCardLeft -
                      horizontalInset * -delta * (isOnRight ? 15 : 1),
                  0.0);

          var cardItem = Positioned.directional(
            top: padding + verticalInset * max(-delta, 0.0),
            bottom: padding + verticalInset * max(-delta, 0.0),
            start: start,
            textDirection: TextDirection.rtl,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.08),
                      offset: const Offset(3.0, 6.0),
                      blurRadius: 8.0,
                    )
                  ],
                ),
                child: AspectRatio(
                  aspectRatio: cardAspectRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      _eventImage(events[i]),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              scheme.scrim.withValues(alpha: 0.12),
                              Colors.transparent,
                              scheme.scrim.withValues(alpha: 0.18),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 12,
                        child: AnimatedBuilder(
                          animation: FavoritesScope.of(context),
                          builder: (context, _) {
                            final favorites = FavoritesScope.of(context);
                            final isFav = favorites.isFavorite(events[i].id);
                            return InkWell(
                              onTap: () => favorites.toggle(events[i].id),
                              borderRadius: BorderRadius.circular(99),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: scheme.scrim.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Icon(
                                  isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: scheme.onPrimaryContainer,
                                  size: 18,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 10),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                events[i].category.isEmpty
                                    ? 'Событие'
                                    : events[i].category,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        height: 172,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: ClipRect(
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                            child: Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.26),
                              alignment: Alignment.center,
                              width: 100.0,
                              height: 150.0,
                              child: _cardInfo(context, i),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        EventDetailsPage(event: events[i])),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          cardList.add(cardItem);
        }
        return Stack(children: cardList);
      }),
    );
  }

  Widget _cardInfo(BuildContext context, int i) {
    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Text(
              events[i].title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                fontFamily: 'SF-Pro-Text-Regular',
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Text(
              events[i].description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'SF-Pro-Text-Regular',
              ),
            ),
          ),
          const SizedBox(height: 6.0),
          Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 22.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                'Возможно пойду',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSecondary),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 6),
            child: InkWell(
              onTap: () =>
                  AnalyticsService.logFriendProofOpened(eventId: events[i].id),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  _socialProof(events[i]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 4),
            child: Builder(
              builder: (context) {
                final meta = _metaLine(events[i]);
                if (meta.isEmpty) return const SizedBox.shrink();
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule, size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _socialProof(Event event) {
    if (event.friendsGoing <= 0) return 'Будь первым из друзей';
    if (event.friendsGoing == 1) return '1 друг уже идет';
    return '${event.friendsGoing} друзей уже идут';
  }

  String _metaLine(Event event) {
    final parts = <String>[];
    final startsAt = event.startsAt;
    if (startsAt != null) {
      final date = '${startsAt.day.toString().padLeft(2, '0')}.'
          '${startsAt.month.toString().padLeft(2, '0')}';
      parts.add(date);
    }
    if (event.place.isNotEmpty) {
      parts.add(event.place);
    }
    if (parts.isEmpty) return '';
    return parts.join(' • ');
  }

  Widget _eventImage(Event event) {
    if (event.imageAsset.startsWith('http')) {
      return Image.network(
        event.imageAsset,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image.asset('images/image_01.png', fit: BoxFit.cover),
      );
    }
    return Image.asset(event.imageAsset, fit: BoxFit.cover);
  }
}
