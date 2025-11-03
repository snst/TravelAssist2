import 'package:flutter/material.dart';
import 'package:travelassist2/widgets/widget_icon_button.dart';

import '../utils/globals.dart';
import '../utils/travel_assist_utils.dart';
import '../widgets/widget_layout.dart';
import 'note.dart';

Future<void> showShowDialog({
  required BuildContext context,
  required Note note,
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          note.comment,
          style: const TextStyle(fontSize: 40.0),
        ),
        content: Text(
          note.link,
          style: const TextStyle(fontSize: 40.0),
        ),
        actions: <Widget>[
          if (note.comment.isNotEmpty)
            WidgetIconButton(icon: MyIcons.copy, onPressed: () => copyToClipboard(context, note.comment)),
          if (note.link.isNotEmpty)
            WidgetIconButton(icon: MyIcons.copy, onPressed: () => copyToClipboard(context, note.link)),
          HSpace(val:4),
          WidgetIconButton(
            icon: MyIcons.cancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}
