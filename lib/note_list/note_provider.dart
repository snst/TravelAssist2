import 'dart:convert';

import '../utils/json_export.dart';
import '../utils/storage.dart';
import 'note.dart';

class NotesResult {
  final List<Note> notes;
  final List<String> tags;
  final List<String> allTags;

  NotesResult({required this.notes, required this.tags, required this.allTags});
}

class NoteProvider extends Storage<Note> implements JsonExport {
  NoteProvider(super.isar);

  Future<List<Note>> getWithTag(List<String> tags) async {
    final all = await getAll(); // await the Future
    if (tags.isEmpty) return all;

    return all.where((bookmark) => tags.every((tag) => bookmark.tags.contains(tag))).toList();
  }

  Future<NotesResult> filterNotesWithTag(List<String> tags) async {
    final all = await getAll(); // await the Future
    final allTags = getUsedTags(all);
    if (tags.isEmpty) return NotesResult(notes: all, tags: allTags, allTags: allTags);
    final filteredNotes = all.where((bookmark) => tags.every((tag) => bookmark.tags.contains(tag))).toList();
    return NotesResult(notes: filteredNotes, tags: getUsedTags(filteredNotes), allTags: allTags);
  }

  List<String> getUsedTags(List<Note> notes) {
    final tags = <String>{};
    for (var item in notes) {
      tags.addAll(item.tags);
    }
    final tagList = tags.toList();
    tagList.sort();
    return tagList;
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

  @override
  Future<String> toJson() async {
    final all = await getAll();
    List<Map<String, dynamic>> jsonList = all.map((item) => item.toJson()).toList();
    return jsonEncode(jsonList);
  }

  @override
  void fromJson(String? jsonString, bool append) {
    if (jsonString != null) {
      if (!append) {
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
