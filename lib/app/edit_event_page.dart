import 'package:flutter/material.dart';
import 'package:my_events/common_widgets/animated_background.dart';
import 'package:my_events/data/event_repository.dart';
import 'package:my_events/models/event.dart';

class EditEventPage extends StatefulWidget {
  const EditEventPage({super.key, required this.event});

  final Event event;

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _repo = const EventRepository();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _placeController;
  late String _category;
  DateTime? _startsAt;
  bool _isSaving = false;

  static const _categories = ['Общее', 'Город', 'Маркет', 'Нетворкинг', 'Лаунж'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(text: widget.event.description);
    _placeController = TextEditingController(text: widget.event.place);
    _category = widget.event.category;
    _startsAt = widget.event.startsAt;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Редактировать событие')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _field('Название', _titleController),
                const SizedBox(height: 12),
                _field('Описание', _descriptionController, maxLines: 3),
                const SizedBox(height: 12),
                _field('Место', _placeController),
                const SizedBox(height: 12),
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
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
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
                          if (_formKey.currentState?.validate() != true) return;
                          setState(() => _isSaving = true);
                          try {
                            await _repo.updateEvent(
                              id: widget.event.id,
                              title: _titleController.text,
                              description: _descriptionController.text,
                              place: _placeController.text,
                              category: _category,
                              startsAt: _startsAt,
                            );
                            if (!mounted) return;
                            Navigator.of(context).pop();
                          } finally {
                            if (mounted) setState(() => _isSaving = false);
                          }
                        },
                  child: Text(_isSaving ? 'Сохраняем...' : 'Сохранить изменения'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String hint, TextEditingController controller, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Поле обязательно' : null,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

