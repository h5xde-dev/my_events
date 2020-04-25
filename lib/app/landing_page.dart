import 'package:flutter/material.dart';
import 'package:my_events/app/sign_in/sign_in_page.dart';
import 'package:my_events/services/auth.dart';
import 'package:my_events/common_widgets/navigation_menu.dart';

import 'dart:async';

class LandingPage extends StatefulWidget {
  LandingPage({
    @required this.auth,
    this.choosenIndex = 0
  });

  final AuthBase auth;
  final int choosenIndex;

  @override
  _LandingPageState createState() => _LandingPageState(choosenIndex: choosenIndex);
}

class _LandingPageState extends State<LandingPage> {

  _LandingPageState({
    this.choosenIndex = 0
  });

  User _user;
  final choosenIndex;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
    widget.auth.onAuthStateChanged.listen((user){
      print('user: ${user?.uid}');
    });
  }

  Future<void> _checkCurrentUser() async {
    User user = await widget.auth.currentUser();
    _updateUser(user);
  }

  void _updateUser(User user) {
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.auth.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          User user = snapshot.data;
          if(user == null) {
            return SignInPage(
              auth: widget.auth,
              onSignIn: _updateUser,
            );
          }
          return Scaffold(
            body: NavigationMenu(auth: Auth(), choosenIndex: choosenIndex,),
          );
        }
        return Text('');
      },
    );
  }
}