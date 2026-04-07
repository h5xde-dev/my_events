import 'package:flutter/material.dart';
import 'package:my_events/app/sign_in/sign_in_page.dart';
import 'package:my_events/services/auth.dart';
import 'package:my_events/common_widgets/navigation_menu.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key, required this.auth});

  final AuthBase auth;

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: widget.auth.onAuthStateChanged,
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) {
          return SignInPage(
            auth: widget.auth,
            onSignIn: (_) {},
          );
        }
        return Scaffold(
          body: NavigationMenu(auth: widget.auth),
        );
      },
    );
  }
}