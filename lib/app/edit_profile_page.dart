import 'package:flutter/material.dart';
import 'package:my_events/app/search_page.dart';
import 'package:my_events/app/shared/widgets/widgets.dart';
import 'package:my_events/data/event_repository.dart';
import 'package:my_events/services/auth.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage(
      {super.key, required this.initialName, required this.initialBio});

  final String initialName;
  final String initialBio;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _repo = const EventRepository();
  final _auth = Auth();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _bioController = TextEditingController(text: widget.initialBio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              AppScreenHeader(
                title: 'Редактировать профиль',
                trailing: AppIconActionButton(
                  icon: Icons.search,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SearchPage()),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Введите имя' : null,
                decoration: const InputDecoration(
                  labelText: 'Имя',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bioController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'О себе',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isSaving
                    ? null
                    : () async {
                        if (_formKey.currentState?.validate() != true) return;
                        setState(() => _isSaving = true);
                        try {
                          final user = await _auth.currentUser();
                          if (user == null) return;
                          await _repo.saveProfile(
                            userId: user.uid,
                            name: _nameController.text,
                            bio: _bioController.text,
                          );
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Профиль обновлен'),
                            ),
                          );
                          Navigator.of(context).pop();
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Не удалось сохранить профиль. $e'),
                            ),
                          );
                        } finally {
                          if (mounted) setState(() => _isSaving = false);
                        }
                      },
                child: Text(_isSaving ? 'Сохраняем...' : 'Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
