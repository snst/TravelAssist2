import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:provider/provider.dart';

import 'bookmark.dart';

class BookmarkProvider extends ChangeNotifier {
  final Isar isar;

  BookmarkProvider(this.isar);

  static BookmarkProvider getInstance(BuildContext context) {
    return Provider.of<BookmarkProvider>(context, listen: false);
  }

  Future<void> add(Bookmark item, {bool notify = false}) async {
    await isar.writeTxn(() async {
      await isar.bookmarks.put(item);
    });
    notifyListeners();
  }

  void addList(List<Bookmark> items) async {
    for (final item in items) {
      await add(item, notify: false);
    }
    notifyListeners();
  }

  Future<void> delete(Bookmark item) async {
    await isar.writeTxn(() async {
      await isar.bookmarks.delete(item.id);
    });
    notifyListeners();
  }

  Future<void> clear() async {
    await isar.writeTxn(() async {
      await isar.bookmarks.clear();
    });
    notifyListeners();
  }

  Future<List<Bookmark>> getAll() async {
    return await isar.bookmarks.where().findAll();
  }

  Future<List<Bookmark>> getWithTag(List<String> tags) async {
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
      List<Bookmark> newItems = jsonList
          .map((json) => Bookmark.fromJson(json))
          .toList();
      clear();
      addList(newItems);
    }
  }
}
