import 'package:flutter/material.dart';
import 'package:my_events/services/auth.dart';

class UserSettings extends StatelessWidget {
  UserSettings({
    @required this.auth,
    @required this.onSignOut
  });

  final VoidCallback onSignOut;
  final AuthBase auth;

  Future<void> _signOut() async {
    try {
      await auth.signOut();
      onSignOut();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {},
          )
        ],      
        ),
      body: Container(),
      );
  }
}