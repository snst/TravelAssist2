import 'package:flutter/material.dart';

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
  final void Function(String?) fromJson;
  final void Function() clearJson;

  @override
  Widget build(BuildContext context) {
    return Row(
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
          child: const Text("Import"),
          onPressed: () {
            Future<String?> jsonData = loadJson();
            jsonData.then((jsonString) {
              fromJson(jsonString);
            });
          },
        ),
        ElevatedButton(
          child: const Text("Clear"),
          onPressed: () {
            clearJson();
          },
        ),
      ],
    );
  }
}
