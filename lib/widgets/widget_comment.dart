import 'package:flutter/material.dart';

/*
class StringHolder {
  String value;

  StringHolder(this.value);
}
*/
class WidgetComment extends StatelessWidget {
  const WidgetComment({
    super.key,
    required this.comment,
    required this.onChanged,
  });

  final String comment;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController()..text = comment,
      decoration: const InputDecoration(hintText: 'Comment'),
      onChanged: (value) => {onChanged(value)},
      keyboardType: TextInputType.multiline,
      minLines: 3,
      maxLines: 3,
    );
  }
}
