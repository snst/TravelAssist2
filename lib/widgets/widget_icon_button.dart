
import 'package:flutter/material.dart';

class WidgetIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPressed;
  final bool enabled;

  const WidgetIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.onLongPressed,
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
      onLongPress: enabled ? onLongPressed : null,
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 30,
          //color: Colors.white,
        ),
      ),
    );
  }
}