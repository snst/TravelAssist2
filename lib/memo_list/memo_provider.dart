import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:provider/provider.dart';

import '../utils/storage.dart';
import 'memo.dart';

class MemoProvider extends ChangeNotifier with Storage {
  MemoProvider({this.useDb = true}) {
    if (useDb) {
      db = openDB();
      init();
    }
  }

  bool useDb;
  List<Memo> _items = [];

  List<Memo> get items => _items;

  void init() async {
    final isar = await db;
    isar!.txn(() async {
      _items = await isar.memos.where().findAll();
      notifyListeners();
    });
  }

  static MemoProvider getInstance(BuildContext context) {
    return Provider.of<MemoProvider>(context, listen: false);
  }

  void add(Memo item) async {
    addList([item]);
  }

  void addList(List<Memo> items) async {
    if (useDb) {
      final isar = await db;
      await isar!.writeTxn(() async {
        for (final item in items) {
          await isar.memos.put(item);
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

  void delete(Memo item) async {
    if (useDb) {
      final isar = await db;
      await isar!.writeTxn(() async {
        await isar.memos.delete(item.id);
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
        await isar.memos.clear();
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
      List<Memo> newItems = jsonList
          .map((json) => Memo.fromJson(json))
          .toList();
      clear();
      addList(newItems);
    }
  }
}
