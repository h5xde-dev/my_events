import 'package:flutter/material.dart';
import 'package:my_events/common_widgets/event_card.dart';
import 'package:my_events/common_widgets/animated_background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_events/common_widgets/animated_loading.dart';

class MainPage extends StatefulWidget {
  MainPage({
    auth,
    onSignOut
  });

  @override
  _MainPageState createState() => new _MainPageState();
}


class _MainPageState extends State<MainPage> {

  List data = [];
  //var _currentPage = data.length - 1.0;
  var currentPage;
  bool futureCompleted = false;

  Future<List> getData() async {
    List dataFire = [];
    Set cardInfo = {};
    await Firestore.instance
        .collection("places")
        .getDocuments()
        .then((QuerySnapshot snapshot) {
          createCards(f) {
            cardInfo.add(f.data);
          }
          snapshot.documents.forEach((f) => createCards(f));
          dataFire.addAll(
            cardInfo
          );
          setState(() {
            currentPage = dataFire.length - 1.0;
            futureCompleted = true;
            data = dataFire;
          });
        });
    return dataFire;
  }

  @override
  Widget build(BuildContext context) {

    PageController controller = PageController(initialPage: data.length - 1);
    controller.addListener(() {
      setState(() {
        currentPage = controller.page;
      });
    });

    if(futureCompleted == false)
    {
      return FutureBuilder(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          switch (snapshot.connectionState) {
          case ConnectionState.none:
            return AnimatedLoading();
          case ConnectionState.waiting:
            return AnimatedLoading();
          default:
            return _buildContent(controller);
          }
        },
      );
    }
    return _buildContent(controller);
  }

  Widget _buildContent( PageController controller) {
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