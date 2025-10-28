import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:provider/provider.dart';

import '../balance/balance.dart';
import '../currency/currency.dart';
import '../currency/currency_provider.dart';
import 'transaction.dart';
import 'transaction_value.dart';

class TransactionProvider extends ChangeNotifier{
  final Isar isar;
  //List<Transaction> _items = [];

  TransactionProvider(this.isar) {
    init();
  }



  static TransactionProvider getInstance(BuildContext context) {
    return Provider.of<TransactionProvider>(context, listen: false);
  }

  void add(Transaction item, {bool notify = true}) async {
    await isar.writeTxn(() async {
      await isar.transactions.put(item);
    });
    if (notify) {
      notifyListeners();
    }
  }

  void addList(List<Transaction> items) async {
    for (final item in items) {
      add(item, notify: false);
    }
    notifyListeners();
  }

  void delete(Transaction item) async {
    await isar.writeTxn(() async {
      await isar.transactions.delete(item.id);
    });
    notifyListeners();
  }

  void clear() async {
    await isar.writeTxn(() async {
      await isar.transactions.clear();
    });
    notifyListeners();
  }

  void init() async {
    //items = await isar.transactions.where().findAll();
    //notifyListeners();
  }

  Future<List<Transaction>> getAll() async {
    return await isar.transactions.where().findAll();
  }

  List<String> getCategoryList(List<Transaction> items) {
    Map<String, int> occurrenceMap = {};
    for (final transaction in items) {
      final str = transaction.category;
      occurrenceMap[str] = (occurrenceMap[str] ?? 0) + 1;
    }
    List<String> sortedUniqueStrings = occurrenceMap.keys.toList()
      ..sort((a, b) => occurrenceMap[b]!.compareTo(occurrenceMap[a]!));

    return sortedUniqueStrings;
  }

  List<String> getPaymentMethodList(List<Transaction> items, bool hideCash) {
    Map<String, int> occurrenceMap = {};
    for (final transaction in items) {
      final str = transaction.method;
      if (str.isNotEmpty && !(hideCash && str == "Cash")) {
        occurrenceMap[str] = (occurrenceMap[str] ?? 0) + 1;
      }
    }
    List<String> sortedUniqueStrings = occurrenceMap.keys.toList()
      ..sort((a, b) => occurrenceMap[b]!.compareTo(occurrenceMap[a]!));

    return sortedUniqueStrings;
  }

  List<Transaction> getSortedTransactions(List<Transaction> all, DateTime? until) {
    List<Transaction> ret = all;
    if (until != null) {
      ret = all.where((element) => !element.date.isAfter(until)).toList();
    }

    ret.sort(transactionComparison);
    return ret;
  }

  int transactionComparison(Transaction a, Transaction b) {
    var ret = a.date.compareTo(b.date);
    return ret;
  }

  List<String> getUsedPaymentMethods(List<Transaction> items) {
    List<String> methods = [];
    for (final transaction in items) {
      if (!methods.contains(transaction.method)) {
        methods.add(transaction.method);
      }
    }
    return methods;
  }

  TransactionValue calcCurrentCash(
  List<Transaction> items,
    CurrencyProvider currencyProvider,
    Currency? currency,
  ) {
    TransactionValue sum = TransactionValue(0, currency);
    if (currency != null) {
      for (final transaction in items) {
        if (transaction.currency == currency.name) {
          final tv = currencyProvider.getTransactionValue(transaction);
          if (transaction.isWithdrawal ||
              transaction.isCashDeposit ||
              transaction.isCashCorrection) {
            sum.add(tv);
          } else if (transaction.isExpense && transaction.isCash) {
            sum.sub(tv);
          }
        }
      }
    }
    return sum;
  }

  Balance caluculateAll(List<Transaction> items, CurrencyProvider currencyProvider) {
    var balance = Balance(currencyProvider: currencyProvider);
    for (final transaction in items) {
      balance.add(transaction);
    }
    return balance;
  }

  Balance caluculateExpensesPerDay(List<Transaction> items, CurrencyProvider currencyProvider) {
    var balance = Balance(currencyProvider: currencyProvider);
    for (final transaction in items) {
      if (transaction.isExpense && transaction.averageDays > 0) {
        //if (transaction.averageDays > 1) {
        //  Transaction t = transaction.clone();
        //  t.value /= transaction.averageDays;
        //  balance.add(t);
        //} else {
        balance.add(transaction);
        //}
      }
    }

    if (items.isNotEmpty) {
      var start = items.first.groupDate;
      var end = items.last.groupDate;
      balance.days = end.difference(start).inDays + 1;

      balance.expenseAll.value /= balance.days;
      balance.expenseCash.value /= balance.days;
      balance.expenseCard.value /= balance.days;

      balance.expenseByMethodCurrencyCash.forEach((key, tv) {
        tv.value /= balance.days;
      });

      balance.expenseByMethod.forEach((key, tv) {
        tv.value /= balance.days;
      });

      balance.expenseByMethodCurrencyCard.forEach((key2, tv) {
        tv.value /= balance.days;
      });
    }

    return balance;
  }

  Future<String> toJson() async {
    List<Transaction> all = await isar.transactions.where().findAll();
    List<Map<String, dynamic>> jsonList = all
        .map((item) => item.toJson())
        .toList();
    return jsonEncode(jsonList);
  }

  void fromJson(String? jsonString) {
    if (jsonString != null) {
      List<dynamic> jsonList = jsonDecode(jsonString);
      List<Transaction> newItems = jsonList
          .map((json) => Transaction.fromJson(json))
          .toList();
      clear();
      addList(newItems);
    }
  }
}
