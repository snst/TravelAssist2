import 'package:flutter/material.dart';
/*
class StringHolder {
  String value;

  StringHolder(this.value);
}
*/
class WidgetComment extends StatelessWidget {
  WidgetComment({super.key, required this.comment, required this.onChanged});

  String comment;
  Function onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController()..text = comment,
      decoration: const InputDecoration(hintText: 'Comment'),
      onChanged: (value) => { onChanged(value) },
      keyboardType: TextInputType.multiline,
      minLines: 3,
      //Normal textInputField will be displayed
      maxLines: 3, // when user presses enter it will adapt to it
    );
  }
}
