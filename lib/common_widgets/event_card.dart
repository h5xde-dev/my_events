import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math';
import 'dart:ui';
class EventCard extends StatelessWidget {
  EventCard({
    this.currentPage,
    this.data,
  });

  final double currentPage;
  final List data;
  final double padding = 20.0;
  final double verticalInset = 20.0;

  @override
  Widget build(BuildContext context) {
    
    var cardAspectRatio = 12.0 / 16.0;
    var widgetAspectRatio = cardAspectRatio * 1.2;

    return new AspectRatio(
      aspectRatio: widgetAspectRatio,
      child: LayoutBuilder(builder: (context, contraints) {
        var width = contraints.maxWidth;
        var height = contraints.maxHeight;

        var safeWidth = width - 2 * padding;
        var safeHeight = height - 2 * padding;

        var heightOfPrimaryCard = safeHeight;
        var widthOfPrimaryCard = heightOfPrimaryCard * cardAspectRatio;

        var primaryCardLeft = safeWidth - widthOfPrimaryCard;
        var horizontalInset = primaryCardLeft / 2;

        List<Widget> cardList = new List();

        for (var i = 0; i < data.length; i++) {
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
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(3.0, 6.0),
                      blurRadius: 10.0)
                ]),
                child: _cardBox(context, cardAspectRatio, i),
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

  Widget _cardBox(context, cardAspectRatio, i){
    print(data[i]['imageBanner']);
    return AspectRatio(
      aspectRatio: cardAspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CachedNetworkImage(
            progressIndicatorBuilder: (context, url, progress) =>
            Center(
              child: CircularProgressIndicator(
                value: progress.progress,
              ),
            ),
            imageUrl: data[i]['imageBanner'],
            fit: BoxFit.fill,
          ),
          Container(
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
                        padding: EdgeInsets.only(
                          left: 16.0, top: 8.0, bottom: 8.0),
                        child: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          radius: 20,
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).backgroundColor,
                            //backgroundImage: AssetImage(data[i]['avatar']??'images/image_01.png'),
                            radius: 18,
                          ),
                        )
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 8.0, right: 16.0, top: 8.0),
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).primaryColor),
                            color: Theme.of(context).backgroundColor,
                            borderRadius: BorderRadius.circular(5.0)
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.0),
                            child: Text(data[i]['name']??'test',
                              style: TextStyle(
                                  color: Theme.of(context).textSelectionColor,
                                  fontSize: 15.0,
                                  fontFamily: "SF-Pro-Text-Regular")),
                          )
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text('test',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontFamily: "SF-Pro-Text-Regular")),
                  ),
                ],
              )
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
                  color: Theme.of(context).textSelectionColor.withOpacity(0.4),
                  alignment: Alignment.center,
                  width: 100.0,
                  height: 150.0,
                  child: _cardInfo(context, i),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardInfo(context, i){
    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 8.0),
            child: Text(data[i]['name']??'test',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontFamily: "SF-Pro-Text-Regular")),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 8.0),
            child: Text(data[i]['description']??'test',
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
                  color: Theme.of(context).secondaryHeaderColor,
                  borderRadius: BorderRadius.circular(20.0)),
              child: Text("Возможно пойду",
                style: TextStyle(color: Colors.white)
              ),
            ),
          ),
        ],
      ),
    );
  }
}