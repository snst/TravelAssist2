import 'dart:convert';

import '../utils/json_export.dart';
import '../utils/storage.dart';
import 'todo_item.dart';

class TodoProvider  extends Storage<TodoItem> implements JsonExport {
  TodoProvider(super.isar);

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

  @override
  Future<String> toJson() async {
    final items = await getAll();
    List<Map<String, dynamic>> jsonList = items
        .map((item) => item.toJson())
        .toList();
    return jsonEncode(jsonList);
  }

  @override
  void fromJson(String? jsonString, bool append) {
    if (jsonString != null) {
      if(!append) {
        clear();
      }
      final jsonList = jsonDecode(jsonString) as List;
      for (var json in jsonList) {
        add(TodoItem.fromJson(json), notify: false);
      }
      notifyListeners();
    }
  }

}
