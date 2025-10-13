import 'package:flutter/material.dart';

class WidgetDualActionButton extends StatelessWidget {
  final VoidCallback onMainPressed;
  final VoidCallback? onAddPressed;
  final String label;
  final IconData icon;

  const WidgetDualActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onMainPressed,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: onMainPressed, // Main press handled here
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          //shape: RoundedRectangleBorder(
          //  borderRadius: BorderRadius.circular(8),
          //),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main icon + label
            Expanded(
              child: Row(
                children: [
                  Icon(icon, size: 28),
                  const SizedBox(width: 8),
                  Text(label, style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),

            if (onAddPressed != null) ...[
              // Divider
              Container(
                width: 1,
                height: 24,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),

              // Secondary add icon
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onAddPressed,
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.add, size: 28),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
