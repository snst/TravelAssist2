import 'package:flutter/material.dart';
import 'package:travelassist2/widgets/widget_confirm_dialog.dart';

import '../utils/travel_assist_utils.dart';

class ExportWidget extends StatelessWidget {
  const ExportWidget({
    super.key,
    required this.name,
    required this.toJson,
    required this.fromJson,
    required this.clearJson,
  });

  final String name;

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
              saveJson(context, name, jsonString);
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
