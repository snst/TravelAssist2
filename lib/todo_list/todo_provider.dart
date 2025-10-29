import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:provider/provider.dart';

import '../utils/storage.dart';
import 'todo_item.dart';

class TodoProvider  extends Storage<TodoItem> {
  TodoProvider(Isar isar) : super(isar);

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
      clear();
      final jsonList = jsonDecode(jsonString) as List;
      for (var json in jsonList) {
        add(TodoItem.fromJson(json), notify: false);
      }
      notifyListeners();
    }
  }

}
