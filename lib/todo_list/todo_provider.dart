import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:provider/provider.dart';

import 'todo_item.dart';

class TodoProvider extends ChangeNotifier {
  final Isar isar;

  TodoProvider(this.isar);

  static TodoProvider getInstance(BuildContext context) {
    return Provider.of<TodoProvider>(context, listen: false);
  }

  Future<List<TodoItem>> getAll() async {
    return await isar.todoItems.where().findAll();
  }

  Future<List<String>> getCategories() async {
    final items = await getAll();
    List<String> ret = [];
    for (final item in items) {
      if (!ret.contains(item.category)) {
        ret.add(item.category);
      }
    }
    ret.sort();
    return ret;
  }

  Future<void> add(TodoItem item, {bool notify = false}) async {
    await isar.writeTxn(() async {
      await isar.todoItems.put(item);
    });
    notifyListeners();
  }

  void addList(List<TodoItem> items) async {
    for (final item in items) {
      await add(item, notify: false);
    }
    notifyListeners();
  }

  Future<void> delete(TodoItem item) async {
    await isar.writeTxn(() async {
      await isar.todoItems.delete(item.id);
    });
    notifyListeners();
  }

  Future<void> clear() async {
    await isar.writeTxn(() async {
      await isar.todoItems.clear();
    });
    notifyListeners();
  }

  Future<List<TodoItem>> getFilteredItems(TodoItemStateEnum state) async {
    final items = await getAll();
    switch (state) {
      case TodoItemStateEnum.done:
        return items.where((i) => i.state == TodoItemStateEnum.done).toList();
      case TodoItemStateEnum.skipped:
        return items
            .where((i) => i.state == TodoItemStateEnum.skipped)
            .toList();
      case TodoItemStateEnum.open:
        return items.where((i) => i.state == TodoItemStateEnum.open).toList();
    }
  }

  Future<String> toJson() async {
    final items = await getAll();
    List<Map<String, dynamic>> jsonList = items
        .map((item) => item.toJson())
        .toList();
    return jsonEncode(jsonList);
  }

  void fromJson(String? jsonString) {
    if (jsonString != null) {
      List<dynamic> jsonList = jsonDecode(jsonString);
      List<TodoItem> newItems = jsonList
          .map((json) => TodoItem.fromJson(json))
          .toList();
      clear();
      addList(newItems);
    }
  }
}
