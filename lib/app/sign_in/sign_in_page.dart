import 'package:flutter/material.dart';
import 'package:my_events/app/sign_in/social_sign_in_button.dart';
import 'package:my_events/app/sign_in/sign_in_button.dart';
import 'package:my_events/services/auth.dart';
import 'package:my_events/common_widgets/animated_background.dart';
import 'dart:async';

class SignInPage extends StatelessWidget {
  SignInPage({
    @required this.auth,
    @required this.onSignIn,
  });
  
  final Function(User) onSignIn;
  final AuthBase auth;

  Future<void> _signInAnonymously() async {
    try {
      User user =  await auth.signInAnonymously();
      onSignIn(user);
    } catch (e) {
      print(e.toString());
    }
  }

  @override

  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        body: __buildContent(),
        backgroundColor: Colors.transparent,
      ),
    );
  }

  Padding __buildContent() {
    return Padding(
        padding:EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Войти',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 48.0),
            SocialSignInButton(
              assetName: 'images/google-logo.png',
              text: 'Войти через гугл',
              textColor: Colors.black,
              color: Colors.white,
              onPressed: _signInAnonymously,
            ),

            SizedBox(height: 8.0),
            Text(
              'or',
              style: TextStyle(fontSize: 14.0, color: Colors.black87),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 8.0),
            SignInButton(
              text: 'Без регистрации',
              textColor: Colors.white,
              color: Colors.green,
              onPressed: _signInAnonymously,
            ),
            
          ],
        )
      );
  }
}