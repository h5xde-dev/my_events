import 'package:flutter/material.dart';
import 'package:my_events/app/search_page.dart';
import 'package:my_events/app/shared/widgets/widgets.dart';
import 'package:my_events/data/event_repository.dart';
import 'package:my_events/data/user_stats_repository.dart';
import 'package:my_events/services/analytics_service.dart';
import 'package:my_events/services/auth.dart';
import 'package:my_events/services/notifications_service.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _repo = const EventRepository();
  final _auth = Auth();
  final _statsRepo = const UserStatsRepository();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _placeController = TextEditingController();
  final _imageController = TextEditingController(text: 'images/image_01.png');
  final _formKey = GlobalKey<FormState>();
  String _category = 'Общее';
  DateTime? _startsAt;
  bool _isSaving = false;
  static const _categories = [
    'Общее',
    'Город',
    'Маркет',
    'Нетворкинг',
    'Лаунж'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _placeController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                AppScreenHeader(
                  title: 'Создать событие',
                  trailing: AppIconActionButton(
                    icon: Icons.search,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SearchPage()),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _field('Название', _titleController),
                const SizedBox(height: 12),
                _field('Описание', _descriptionController, maxLines: 3),
                const SizedBox(height: 12),
                _field('Место', _placeController),
                const SizedBox(height: 12),
                _field('Картинка (URL или asset)', _imageController),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v ?? 'Общее'),
                  decoration: const InputDecoration(
                    labelText: 'Категория',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDate: _startsAt ?? DateTime.now(),
                    );
                    if (picked != null) setState(() => _startsAt = picked);
                  },
                  child: Text(
                    _startsAt == null
                        ? 'Выбрать дату'
                        : 'Дата: ${_startsAt!.day}.${_startsAt!.month}.${_startsAt!.year}',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          if (_formKey.currentState?.validate() != true) {
                            return;
                          }
                          setState(() => _isSaving = true);
                          try {
                            final user = await _auth.currentUser();
                            if (user == null) {
                              throw StateError('Пользователь не авторизован');
                            }
                            await _repo.createEvent(
                              title: _titleController.text,
                              description: _descriptionController.text,
                              address: _placeController.text,
                              latitude: 55.751244,
                              longitude: 37.618423,
                              category: _category,
                              imageUrl: _imageController.text,
                              startsAt: _startsAt,
                              createdBy: user.uid,
                            );

                            await _statsRepo.onEventCreated(
                              userId: user.uid,
                              at: DateTime.now(),
                            );
                            await AnalyticsService.logCreateEvent(
                              category: _category,
                            );
                            await NotificationsService.scheduleLocalReminder(
                              id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                              title: 'Событие сохранено',
                              body:
                                  'Добавили "${_titleController.text.trim()}" в список',
                            );
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Событие создано'),
                              ),
                            );
                            Navigator.of(context).pop();
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Не удалось сохранить событие. $e'),
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setState(() => _isSaving = false);
                            }
                          }
                        },
                  child: Text(_isSaving ? 'Сохраняем...' : 'Сохранить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String hint, TextEditingController controller,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Поле обязательно' : null,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.85),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
