
import 'package:flutter/material.dart';

class WidgetIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const WidgetIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(14),
      ),
      onPressed: onPressed,
      child: Icon(icon, size: 32),
    );
  }
}