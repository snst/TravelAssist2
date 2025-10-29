import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';

import '../utils/storage_item.dart';

class Storage<T extends StorageItem> extends ChangeNotifier {
  final Isar isar;

  Storage(this.isar);

  Future<void> add(T item, {bool notify = true}) async {
    await isar.writeTxn(() async {
      await isar.collection<T>().put(item);
    });
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> delete(T item) async {
    await isar.writeTxn(() async {
      await isar.collection<T>().delete(item.getId());
    });
    notifyListeners();
  }

  Future<void> clear() async {
    await isar.writeTxn(() async {
      await isar.collection<T>().clear();
    });
    notifyListeners();
  }

  Future<List<T>> getAll() async {
    return await isar.collection<T>().where().findAll();
  }
}
