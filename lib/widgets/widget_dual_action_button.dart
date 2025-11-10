import 'package:flutter/material.dart';
import 'package:travelassist2/widgets/widget_layout.dart';

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
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: SizedBox(
        height: 64,
        child: ElevatedButton(
          onPressed: onMainPressed,
          // Main press handled here
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(icon, size: 28, color: Colors.white),
                    const HSpace(val: 2),
                    Text(label, style: const TextStyle(fontSize: 18, color: Colors.white)),
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
                    child: Icon(Icons.add, size: 28, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
