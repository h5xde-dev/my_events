import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import 'package:my_events/app/event_details_page.dart';
import 'package:my_events/models/event.dart';
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
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  const BoxShadow(
                    color: Colors.black12,
                    offset: Offset(3.0, 6.0),
                    blurRadius: 10.0,
                  )
                ]),
                child: AspectRatio(
                  aspectRatio: cardAspectRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      _eventImage(events[i]),
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
                                  color: Colors.black.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Icon(
                                  isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16.0,
                                      top: 8.0,
                                      bottom: 8.0,
                                    ),
                                    child: CircleAvatar(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      radius: 20,
                                      child: CircleAvatar(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        radius: 18,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8.0,
                                      right: 16.0,
                                      top: 8.0,
                                    ),
                                    child: Container(
                                      height: 20,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6.0,
                                        ),
                                        child: Text(
                                          events[i].description,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            fontSize: 15.0,
                                            fontFamily: "SF-Pro-Text-Regular",
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  events[i].description,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                    fontFamily: "SF-Pro-Text-Regular",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        height: 150,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 10.0,
                              sigmaY: 10.0,
                            ),
                            child: Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.4),
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
                                      EventDetailsPage(event: events[i]),
                                ),
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
        return Stack(
          children: cardList,
        );
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
            padding: EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 8.0),
            child: Text(events[i].title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontFamily: "SF-Pro-Text-Regular")),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 8.0),
            child: Text(events[i].description,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontFamily: "SF-Pro-Text-Regular")),
          ),
          SizedBox(
            height: 10.0,
          ),                 
          Padding(
            padding: const EdgeInsets.only(
                left: 12.0, bottom: 12.0),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 22.0, vertical: 6.0),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(20.0)),
              child: Text("Возможно пойду",
                style: TextStyle(color: Colors.white)
              )
            ),
          ),
        ],
      ),
    );
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