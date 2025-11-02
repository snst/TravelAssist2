import 'package:flutter/material.dart';

import 'widget_icon_button.dart';

class WidgetDateChooser extends StatefulWidget {
  const WidgetDateChooser({
    super.key,
    required this.date,
    required this.onChanged,
  });

  final DateTime date;
  final Function(DateTime) onChanged;

  @override
  State<WidgetDateChooser> createState() => _WidgetDateChooserState();
}

class _WidgetDateChooserState extends State<WidgetDateChooser> {
  DateTime? date;

  @override
  Widget build(BuildContext context) {
    date ??= widget.date;

    return WidgetIconButton(
      icon: Icons.calendar_month,
      onPressed: () {
        selectDate(context);
      },
    );
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != date) {
      setState(() {
        date = picked;
        widget.onChanged(date!);
      });
    }
  }
}
