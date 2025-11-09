import 'package:flutter/material.dart';
import '../utils/travel_assist_utils.dart';
import 'widget_icon_button.dart';
import 'widget_text_input.dart';

import '../utils/globals.dart';

class WidgetTextLink extends StatelessWidget {
  const WidgetTextLink({
    super.key,
    required this.text,
    required this.hintText,
    required this.onChanged,
  });

  final String text;
  final String hintText;
  final void Function(String value) onChanged;

  @override
  Widget build(BuildContext context) {
    return
    Row(
      children:
      [
        Expanded(
          child: WidgetTextInput(
            text: text,
            hintText: Txt.hintLink,
            onChanged: (value) => onChanged(value),
          ),
        ),
        WidgetIconButton(
          icon: MyIcons.link,
          onPressed: () {
            openLinkExternally(context, text);
          },
        ),
      ],);
  }}