import 'package:flutter/material.dart';
import 'package:my_events/app/edit_profile_page.dart';
import 'package:my_events/common_widgets/animated_background.dart';
import 'package:my_events/data/event_repository.dart';
import 'package:my_events/services/auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Auth();
    final repo = const EventRepository();

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<User?>(
          future: auth.currentUser(),
          builder: (context, userSnapshot) {
            final user = userSnapshot.data;
            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return StreamBuilder<Map<String, dynamic>?>(
              stream: repo.watchProfile(user.uid),
              builder: (context, profileSnapshot) {
                final profile = profileSnapshot.data ?? const {};
                final name = (profile['name'] as String?) ?? 'Пользователь';
                final bio = (profile['bio'] as String?) ?? 'Добавьте информацию о себе';

                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Профиль',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 42,
                            fontFamily: "Calibre-Semibold",
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          tileColor: Colors.white.withValues(alpha: 0.14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            bio,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            color: Colors.white,
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EditProfilePage(
                                  initialName: name,
                                  initialBio: bio,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

