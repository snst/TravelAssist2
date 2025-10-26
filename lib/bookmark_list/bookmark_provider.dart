import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:provider/provider.dart';
import 'bookmark.dart';
import '../utils/storage.dart';

class BookmarkProvider extends ChangeNotifier with Storage {
  BookmarkProvider({this.useDb = true}) {
    if (useDb) {
      db = openDB();
      init();
    }
  }

  bool useDb;
  List<Bookmark> _items = [];

  List<Bookmark> get items => _items;

  List<Bookmark> getItemsWithTag(List<String> tags)
  {
    if (tags.isEmpty) return _items;
    return _items.where((bookmark) =>
        tags.every((tag) => bookmark.tags.contains(tag))).toList();
  }

  void init() async {
    final isar = await db;
    isar!.txn(() async {
      _items = await isar.bookmarks.where().findAll();
      notifyListeners();
    });
  }

  static BookmarkProvider getInstance(BuildContext context) {
    return Provider.of<BookmarkProvider>(context, listen: false);
  }

  List<String> getTags() {
    final tags = <String>{};
    _items.forEach((item) => tags.addAll(item.tags));
    final tagList = tags.toList();
    tagList.sort();
    return tagList;
  }


  void add(Bookmark item) async {
    addList([item]);
  }

  void addList(List<Bookmark> items) async {
    if (useDb) {
      final isar = await db;
      await isar!.writeTxn(() async {
        for (final item in items) {
          await isar.bookmarks.put(item);
          if (!_items.contains(item)) {
            _items.add(item);
          }
        }
        notifyListeners();
      });
    } else {
      for (final item in items) {
        if (!_items.contains(item)) {
          _items.add(item);
        }
      }
      notifyListeners();
    }
  }

  void delete(Bookmark item) async {
    if (useDb) {
      final isar = await db;
      await isar!.writeTxn(() async {
        await isar.bookmarks.delete(item.id);
        _items.remove(item);
        notifyListeners();
      });
    } else {
      _items.remove(item);
      notifyListeners();
    }
  }

  void clear() async {
    if (useDb) {
      final isar = await db;
      await isar!.writeTxn(() async {
        await isar.bookmarks.clear();
        _items.clear();
        notifyListeners();
      });
    } else {
      _items.clear();
      notifyListeners();
    }
  }

  String toJson() {
    List<Map<String, dynamic>> jsonList = _items
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
