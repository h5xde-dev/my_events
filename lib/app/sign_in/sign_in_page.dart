import 'package:flutter/material.dart';
import 'package:my_events/app/sign_in/social_sign_in_button.dart';
import 'package:my_events/app/sign_in/sign_in_button.dart';
import 'package:my_events/app/shared/widgets/widgets.dart';
import 'package:my_events/services/auth.dart';

class SignInPage extends StatelessWidget {
  SignInPage({
    super.key,
    required this.auth,
    required this.onSignIn,
  });
  
  final ValueChanged<User> onSignIn;
  final AuthBase auth;

  Future<void> _signInWithGoogle() async {
    try {
      final user = await auth.signInWithGoogle();
      onSignIn(user);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _signInAnonymously() async {
    try {
      final user = await auth.signInAnonymously();
      onSignIn(user);
    } catch (e) {
      debugPrint(e.toString());
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
        padding: const EdgeInsets.all(16.0),
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
            const SizedBox(height: 48.0),
            SocialSignInButton(
              assetName: 'images/google-logo.png',
              text: 'Войти через гугл',
              textColor: Colors.black,
              color: Colors.white,
              onPressed: _signInWithGoogle,
            ),

            const SizedBox(height: 8.0),
            const Text(
              'or',
              style: TextStyle(fontSize: 14.0, color: Colors.black87),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8.0),
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