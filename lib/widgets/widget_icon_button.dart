
import 'package:flutter/material.dart';

class WidgetIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool enabled;

  const WidgetIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.enabled=true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding:  EdgeInsets.zero,
      ),
      onPressed: enabled ? onPressed : null,
      child: Container(
        width: 50, // fixed width
        height: 50, // fixed height
        alignment: Alignment.center, // center the icon
        child: Icon(
          icon,
          size: 30,
          //color: Colors.white,
        ),
      ),
    );
  }
}