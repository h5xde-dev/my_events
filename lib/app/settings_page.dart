import 'package:flutter/material.dart';
import 'package:my_events/services/auth.dart';
import 'package:my_events/services/customisation.dart';
import 'package:my_events/common_widgets/animated_background.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.auth});

  final AuthBase auth;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedTheme = 'pink';

  @override
  void initState() {
    super.initState();
    _selectedTheme = Customisation.themeNotifier.value.colorScheme.primary ==
            Colors.purple
        ? 'purple'
        : 'pink';
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await widget.auth.signOut();
      onSignOut(context);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void onSignOut(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
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
                    IconButton(
                      icon: Icon(
                        Icons.account_circle,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 30.0,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.exit_to_app,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 30.0,
                      ),
                      onPressed: () => _signOut(context),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(
                      width: 100,
                      child: DropdownButton<String>(
                        value: _selectedTheme,
                        items: Customisation.themesList,
                        onChanged: (item) {
                          if (item == null) return;
                          setState(() => _selectedTheme = item);
                          Customisation.changeTheme(item);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}