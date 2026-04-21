import 'package:flutter/material.dart';
import 'package:my_events/app/navigation/widgets/widgets.dart';
import 'package:my_events/app/sign_in/sign_in_page.dart';
import 'package:my_events/services/auth.dart';
import 'package:my_events/state/favorites_scope.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key, required this.auth});

  final AuthBase auth;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  String? _boundUid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: widget.auth.onAuthStateChanged,
      builder: (context, snapshot) {
        final user = snapshot.data;
        debugPrint(
          'Landing auth state: hasData=${snapshot.hasData} uid=${user?.uid}',
        );
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
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ProfilePicture(userId: user.uid),
                SearchButton(),
              ],
            ),
          ),
          body: NavigationMenu(auth: widget.auth),
        );
      },
    );
  }
}

class ProfilePicture extends StatelessWidget {
  const ProfilePicture({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        radius: 24,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Container(
              decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(100),
            image: DecorationImage(
              image: NetworkImage('https://i.pravatar.cc/100?u=$userId'),
              fit: BoxFit.cover,
            ),
          )),
        ));
  }
}

class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Поиск',
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Поиск скоро будет здесь')),
        );
      },
      icon: const Icon(Icons.search),
    );
  }
}
