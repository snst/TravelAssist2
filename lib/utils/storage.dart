import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../currency/currency.dart';
import '../location_list/location.dart';
import '../memo_list/memo.dart';
import '../todo_list/todo_item.dart';
import '../transaction_list/transaction.dart';
import '../note_list/note.dart';

mixin Storage {
  late Future<Isar?> db;

  Future<Isar?> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [
          CurrencySchema,
          TodoItemSchema,
          TransactionSchema,
          LocationSchema,
          MemoSchema,
          NoteSchema,
        ],
        directory: dir.path,
        inspector: true,
      );
    }

    return Isar.getInstance();
  }
}
