import 'package:flutter/material.dart';
import 'package:my_events/common_widgets/animated_background.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _placeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
        appBar: AppBar(
          title: const Text('Создать событие'),
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: Padding(
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
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() != true) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Форма сохранена (mock)'),
                        ),
                      );
                    },
                    child: const Text('Сохранить'),
                  ),
                ],
              ),
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

