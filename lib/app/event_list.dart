import 'package:flutter/material.dart';
import 'package:my_events/services/auth.dart';
import 'package:my_events/common_widgets/animated_background.dart';

class EventList extends StatelessWidget {
  EventList({
    @required this.auth,
  });

  final AuthBase auth;

  @override
  Widget build(BuildContext context) {

    Future<User> _checkCurrentUser() async {
      User _user = await Auth().currentUser();
      return _user;
    }
    
    return FutureBuilder(
      future: _checkCurrentUser(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Center(
                child:CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  strokeWidth: 2.0,
                )
              );
          case ConnectionState.waiting:
            return Center(
                child:CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  strokeWidth: 2.0,
                )
              );
          default:
            if (snapshot.hasError)
              return CircularProgressIndicator();
            else {
              return _buildContent(context, snapshot.data);
            }
        }
      });
  }

  Widget _buildContent(context, user) {
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

                  ],
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }
}