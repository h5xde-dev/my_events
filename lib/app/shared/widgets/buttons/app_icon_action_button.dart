import 'package:flutter/material.dart';

class AppIconActionButton extends StatelessWidget {
  const AppIconActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 30,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: size,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
