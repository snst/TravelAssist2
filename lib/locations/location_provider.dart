import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:provider/provider.dart';
import 'location.dart';
import '../utils/storage.dart';

class LocationProvider extends ChangeNotifier with Storage {
  LocationProvider({this.useDb = true}) {
    if (useDb) {
      db = openDB();
      init();
    }
  }

  bool useDb;
  List<Location> _items = [];
  List<Location> get items => _items;

  void init() async {
    final isar = await db;
    isar!.txn(() async {
      _items = await isar.locations.where().findAll();
      notifyListeners();
    });
  }

  static LocationProvider getInstance(BuildContext context) {
    return Provider.of<LocationProvider>(context, listen: false);
  }

  void add(Location item) async {
    addList([item]);
  }

  void addList(List<Location> items) async {
    if (useDb) {
      final isar = await db;
      await isar!.writeTxn(() async {
        for (final item in items) {
          await isar.locations.put(item);
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

  void delete(Location item) async {
    if (useDb) {
      final isar = await db;
      await isar!.writeTxn(() async {
        await isar.locations.delete(item.id);
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
        await isar.locations.clear();
        _items.clear();
        notifyListeners();
      });
    } else {
      _items.clear();
      notifyListeners();
    }
  }

  String toJson() {
    List<Map<String, dynamic>> jsonList =
    _items.map((item) => item.toJson()).toList();
    return jsonEncode(jsonList);
  }

  void fromJson(String? jsonString) {
    if (jsonString != null) {
      List<dynamic> jsonList = jsonDecode(jsonString);
      List<Location> newItems =
      jsonList.map((json) => Location.fromJson(json)).toList();
      clear();
      addList(newItems);
    }
  }
}
