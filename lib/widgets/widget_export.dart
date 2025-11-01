import 'package:flutter/material.dart';
import 'package:travelassist2/widgets/widget_confirm_dialog.dart';

import '../utils/travel_assist_utils.dart';

class WidgetExport extends StatelessWidget {
  const WidgetExport({
    super.key,
    required this.fileName,
    required this.toJson,
    required this.fromJson,
    required this.clearJson,
  });

  final String fileName;

  final Future<String> Function() toJson;
  final void Function(String?, bool) fromJson;
  final void Function() clearJson;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          child: const Text("Export"),
          onPressed: () {
            Future<String> data = toJson();
            data.then((jsonString) {
              if (context.mounted) {
                saveJson(context, fileName, jsonString);
              }
            });
            }
        ),
        ElevatedButton(
          child: const Text("Import (Replace)"),
          onPressed: () {
            Future<String?> jsonData = loadJson();
            jsonData.then((jsonString) {
              fromJson(jsonString, false);
            });
          },
        ),
        ElevatedButton(
          child: const Text("Import (Append)"),
          onPressed: () {
            Future<String?> jsonData = loadJson();
            jsonData.then((jsonString) {
              fromJson(jsonString, true);
            });
          },
        ),
        ElevatedButton(
          child: const Text("Clear"),
          onPressed: () {
            showConfirmationDialog(
              context: context,
              title: 'Confirm Delete',
              text: 'Are you sure you want to delete these items?',
              onConfirm: () {
                clearJson();
              },
            );

          },
        ),
      ],
    );
  }
}
