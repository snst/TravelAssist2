import 'package:flutter/material.dart';

import '../utils/globals.dart';

class WidgetMultiLineInput extends StatelessWidget {
  const WidgetMultiLineInput({
    super.key,
    required this.onChanged,
    this.initalText = "",
    this.hintText = "",
    this.lines = 3,
  });

  final Function onChanged;
  final String initalText;
  final String hintText;
  final int lines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController()..text = initalText,
      decoration: InputDecoration(
        hintText: hintText,
        border: BorderStyles.input,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
      ),
      onChanged: (value) => onChanged(value),
      autofocus: false,
      keyboardType: TextInputType.multiline,
      minLines: lines,
      maxLines: lines,

    );
  }
}
