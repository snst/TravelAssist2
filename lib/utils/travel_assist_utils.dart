import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

openExternally(BuildContext context, String link) async {
  if (link.startsWith('http')) {
    await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
  } else if (link.startsWith("geo:")) {
    String pos = link.substring(4);
    final url = Uri.parse(
      'geo:$pos?q=$pos(Here)',
    );
    await launchUrl(url);
  }
  else if (File(link).existsSync()) {
    OpenAppFile.open(link);
  } else {
    Clipboard.setData(
      ClipboardData(text: link),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Copied to Clipboard')));
  }
}

Future<String?> getBookmarkFolder() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? path = prefs.getString('bookmarks');
  if (path == null) {
    path = await selectBookmarkFolder();
  }
  return path;
}

void setBookmarkFolder(String path) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('bookmarks', path);
}

Future<String?> selectBookmarkFolder() async {
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

  if (selectedDirectory != null) {
    setBookmarkFolder(selectedDirectory);
  }
  return selectedDirectory;
}

double safeConvertToDouble(String input) {
  input = input.replaceAll(',', '.');
  List<String> parts = input.split('.');
  if (parts.length >= 3) {
    input = '${parts[0]}.${parts[1]}';
  }

  try {
    return double.parse(input);
  } catch (e) {
    return 0.0;
  }
}

String removeTrailingZeros(String inputString) {
  if (inputString.endsWith('.00')) {
    return inputString.substring(0, inputString.length - 3);
  }
  return inputString;
}

String formatDateWithoutTime(DateTime dateTime) {
  final formatter = DateFormat('dd.MM.yyyy');
  return formatter.format(dateTime);
}

void showInputDialog(BuildContext context, String value, Function func) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      TextEditingController nameController = TextEditingController();
      nameController.text = value;
      return AlertDialog(
        title: const Text('Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Name'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              //value = nameController.text;
              func(nameController.text);
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

void saveJson(BuildContext context, String filename, String jsonString) async {
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

  if (selectedDirectory != null) {
    showInputDialog(context, filename, (name) {
      String filePath = path.join(selectedDirectory, "$name.json");
      File(filePath).writeAsStringSync(jsonString);
    });
  }
}

Future<String?> loadJson() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null) {
    File file = File(result.files.single.path!);
    return file.readAsString();
  } else {
    return null;
  }
}
