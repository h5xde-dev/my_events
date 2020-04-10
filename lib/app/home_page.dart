import 'package:flutter/material.dart';
import 'package:my_events/services/auth.dart';
import 'package:my_events/common_widgets/event_card.dart';
import 'package:my_events/common_widgets/navigation_menu.dart';

class HomePage extends StatelessWidget {
  HomePage({
    @required this.auth,
    @required this.onSignOut
  });

  final VoidCallback onSignOut;
  final AuthBase auth;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
            
            title: Directionality(
                textDirection: Directionality.of(context),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0
                    ),
                    decoration: InputDecoration(
                        hintStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0
                        ),
                        border: null
                    ),
                  ),
                )
            ),
          ),
        ),
      body: __buildContent(context),
      bottomNavigationBar: NavigationMenu(),
      );
  }

  Padding __buildContent(context) {
    return Padding(
        padding:EdgeInsets.only(top: 15, left: 15, right: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Мерроприятия вашего города:',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: __screenHeight(context),
              child: ListView(
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  EventCard(),
                  EventCard(),
                  EventCard(),
                  EventCard(),
                  EventCard(),
                ],
              ),
            ),
          ],
        ),
      );
  }

  Size __screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  double __screenHeight(BuildContext context) {
    return __screenSize(context).height - 183;
  }
}