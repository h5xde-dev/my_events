import 'package:flutter/material.dart';
import 'package:my_events/app/navigation/widgets/widgets.dart';
import 'package:my_events/app/sign_in/sign_in_page.dart';
import 'package:my_events/services/auth.dart';
import 'package:my_events/state/favorites_scope.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key, required this.auth});

  final AuthBase auth;

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  String? _boundUid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: widget.auth.onAuthStateChanged,
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (_boundUid != user?.uid) {
          _boundUid = user?.uid;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            FavoritesScope.of(context).bindUser(_boundUid);
          });
        }
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