import 'package:flutter/material.dart';
import 'package:my_events/common_widgets/event_card.dart';
import 'package:my_events/common_widgets/animated_background.dart';

class MainPage extends StatefulWidget {
  MainPage({
    auth,
    onSignOut
  });

  @override
  _MainPageState createState() => new _MainPageState();
}

List data = [
    {
      'title': 'Дегустация табака',
      'image': 'images/image_01.png',
    },
    {
      'title': 'День города',
      'image': 'images/image_02.jpg',
    },
    {
      'title': 'Ярмарка говна',
      'image': 'images/image_03.jpg',
    },
    {
      'title': 'Кофе вечер',
      'image': 'images/image_04.jpg',
    }
];

class _MainPageState extends State<MainPage> {

  var currentPage = data.length - 1.0;

  @override
  Widget build(BuildContext context) {
    PageController controller = PageController(initialPage: data.length - 1);
    controller.addListener(() {
      setState(() {
        currentPage = controller.page;
      });
    });
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 12.0, right: 12.0, top: 30.0, bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.account_circle,
                        color: Theme.of(context).textSelectionColor,
                        size: 30.0,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.search,
                        color: Theme.of(context).textSelectionColor,
                        size: 30.0,
                      ),
                      onPressed: () {},
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Популярные",
                        style: TextStyle(
                          color: Theme.of(context).textSelectionColor,
                          fontSize: 46.0,
                          fontFamily: "Calibre-Semibold",
                          letterSpacing: 1.0,
                        )),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 22.0, vertical: 6.0),
                          child: Text("Рекомендуем",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Text("25+ Событий",
                        style: TextStyle(color: Theme.of(context).secondaryHeaderColor))
                  ],
                ),
              ),
              Stack(
                children: <Widget>[
                  EventCard(
                    currentPage:currentPage,
                    data:data,
                  ),
                  Positioned.fill(
                    child: PageView.builder(
                      itemCount: data.length,
                      controller: controller,
                      reverse: true,
                      itemBuilder: (context, index) {
                        return Container();
                      },
                    ),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Избранные",
                        style: TextStyle(
                          color: Theme.of(context).textSelectionColor,
                          fontSize: 46.0,
                          fontFamily: "Calibre-Semibold",
                          letterSpacing: 1.0,
                        )),
                    IconButton(
                      icon: Icon(
                        Icons.favorite,
                        size: 30.0,
                        color: Theme.of(context).textSelectionColor,
                      ),
                      onPressed: () {},
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 22.0, vertical: 6.0),
                          child: Text("Предстоящие",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Text("9+ Событий",
                        style: TextStyle(color: Theme.of(context).secondaryHeaderColor))
                  ],
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 18.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.asset("images/image_02.jpg",
                          width: 296.0, height: 222.0),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}