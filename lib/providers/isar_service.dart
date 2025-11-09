import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../note_list/note.dart';
import '../currency/currency.dart';
import '../todo_list/todo_item.dart';
import '../transaction_list/transaction.dart';
import '../place_list/place.dart';

class IsarService extends ChangeNotifier {
  Isar? _isar;

  Isar get isar {
    if (_isar == null) {
      throw Exception('Isar has not been initialized yet.');
    }
    return _isar!;
  }

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        CurrencySchema,
        TodoItemSchema,
        TransactionSchema,
        NoteSchema,
        PlaceSchema,
      ],
      directory: dir.path,
      //      inspector: true,
    );
  }

  @override
  void dispose() {
    _isar?.close();
    super.dispose();
  }
}
