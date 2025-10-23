import 'package:flutter/material.dart';

class StringHolder {
  String value;

  StringHolder(this.value);
}

class WidgetComment extends StatelessWidget {
  WidgetComment({super.key, required this.comment});

  StringHolder comment;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController()..text = comment.value,
      decoration: const InputDecoration(hintText: 'Comment'),
      onChanged: (value) => comment.value = value,
      keyboardType: TextInputType.multiline,
      minLines: 3,
      //Normal textInputField will be displayed
      maxLines: 3, // when user presses enter it will adapt to it
    );
  }
}
