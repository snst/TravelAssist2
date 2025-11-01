import 'package:flutter/material.dart';

import '../utils/globals.dart';

class WidgetTextInput extends StatelessWidget {
  const WidgetTextInput({
    super.key,
    required this.text,
    required this.hintText,
    required this.onChanged,
    this.autofocus = false,
    this.lines = 1,
  });

  final String text;
  final String hintText;
  final void Function(String value) onChanged;
  final bool autofocus;
  final int lines;

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    controller.text = text;
    if (lines <= 1) {
      return TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: BorderStyles.input,
          hintText: hintText,
          suffixIcon: IconButton(
            onPressed: controller.clear,
            icon: const Icon(Icons.clear),
          ),
        ),
        onChanged: (value) => onChanged(value),
        autofocus: autofocus,
      );
    } else {
      return TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: BorderStyles.input,
          hintText: hintText,
          suffixIcon: IconButton(
            onPressed: controller.clear,
            icon: const Icon(Icons.clear),
          ),
        ),
        onChanged: (value) => onChanged(value),
        keyboardType: TextInputType.multiline,
        minLines: 1,
        //Normal textInputField will be displayed
        maxLines: lines,
        // when user presses enter it will adapt to it
        autofocus: autofocus,
      );
    }
  }
}
