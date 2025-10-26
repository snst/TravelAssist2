import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:provider/provider.dart';

import 'note.dart';

class NoteProvider extends ChangeNotifier {
  final Isar isar;

  NoteProvider(this.isar);

  static NoteProvider getInstance(BuildContext context) {
    return Provider.of<NoteProvider>(context, listen: false);
  }

  Future<void> add(Note item, {bool notify = false}) async {
    await isar.writeTxn(() async {
      await isar.notes.put(item);
    });
    notifyListeners();
  }

  void addList(List<Note> items) async {
    for (final item in items) {
      await add(item, notify: false);
    }
    notifyListeners();
  }

  Future<void> delete(Note item) async {
    await isar.writeTxn(() async {
      await isar.notes.delete(item.id);
    });
    notifyListeners();
  }

  Future<void> clear() async {
    await isar.writeTxn(() async {
      await isar.notes.clear();
    });
    notifyListeners();
  }

  Future<List<Note>> getAll() async {
    return await isar.notes.where().findAll();
  }

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
    all.forEach((item) => tags.addAll(item.tags));
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

  void fromJson(String? jsonString) {
    if (jsonString != null) {
      List<dynamic> jsonList = jsonDecode(jsonString);
      List<Note> newItems = jsonList
          .map((json) => Note.fromJson(json))
          .toList();
      clear();
      addList(newItems);
    }
  }
}
