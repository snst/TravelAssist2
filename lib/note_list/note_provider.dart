import 'dart:convert';

import '../utils/storage.dart';
import 'note.dart';


class NoteProvider extends Storage<Note> {
  NoteProvider(super.isar);

  Future<List<Note>> getWithTag(List<String> tags) async {
    final all = await getAll(); // await the Future
    if (tags.isEmpty) return all;

    return all
        .where((bookmark) => tags.every((tag) => bookmark.tags.contains(tag)))
        .toList();
  }

  Future<List<String>> getTags() async {
    final tags = <String>{};
    final all = await getAll();
    for (var item in all) {
      tags.addAll(item.tags);
    }
    final tagList = tags.toList();
    tagList.sort();
    return tagList;
  }

  Future<String> toJson() async {
    final all = await getAll();
    List<Map<String, dynamic>> jsonList = all
        .map((item) => item.toJson())
        .toList();
    return jsonEncode(jsonList);
  }

  void fromJson(String? jsonString, bool append) {
    if (jsonString != null) {
      if(!append) {
        clear();
      }
      final jsonList = jsonDecode(jsonString) as List;
      for (var json in jsonList) {
        add(Note.fromJson(json), notify: false);
      }
      notifyListeners();
    }
  }
}
