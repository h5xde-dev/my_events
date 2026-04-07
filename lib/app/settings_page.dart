import 'package:flutter/material.dart';
import 'package:my_events/app/shared/widgets/widgets.dart';
import 'package:my_events/services/auth.dart';
import 'package:my_events/services/customisation.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.auth});

  final AuthBase auth;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedTheme = 'pink';
  ThemeMode _selectedThemeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _selectedTheme = Customisation.themeNameNotifier.value;
    _selectedThemeMode = Customisation.themeModeNotifier.value;
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
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Настройки',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: scheme.onSurface,
                        ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => _signOut(context),
                    icon: const Icon(Icons.exit_to_app),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Режим темы', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      AppDropdownField<ThemeMode>(
                        value: _selectedThemeMode,
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('Как в системе'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('Светлая'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('Тёмная'),
                          ),
                        ],
                        onChanged: (mode) {
                          if (mode == null) return;
                          setState(() => _selectedThemeMode = mode);
                          Customisation.changeThemeMode(mode);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Акцентный цвет', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      AppDropdownField<String>(
                        value: _selectedTheme,
                        items: Customisation.themesList,
                        onChanged: (item) {
                          if (item == null) return;
                          setState(() => _selectedTheme = item);
                          Customisation.changeTheme(item);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}