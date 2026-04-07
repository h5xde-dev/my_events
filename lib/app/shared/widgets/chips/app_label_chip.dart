import 'package:flutter/material.dart';

class AppLabelChip extends StatelessWidget {
  const AppLabelChip({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
      child: Text(
        label,
        style: TextStyle(color: scheme.onPrimary),
      ),
    );
  }
}
