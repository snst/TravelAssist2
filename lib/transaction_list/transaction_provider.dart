import 'dart:convert';

import 'package:isar_community/isar.dart';

import '../balance/balance.dart';
import '../currency/currency.dart';
import '../currency/currency_provider.dart';
import '../utils/storage.dart';
import 'transaction.dart';
import 'transaction_value.dart';

class TransactionProvider extends Storage<Transaction> {
  TransactionProvider(super.isar);

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

  List<Transaction> getSortedTransactions(
    List<Transaction> all,
    DateTime? until,
  ) {
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

  Balance caluculateAll(
    List<Transaction> items,
    CurrencyProvider currencyProvider,
  ) {
    var balance = Balance(currencyProvider: currencyProvider);
    for (final transaction in items) {
      balance.add(transaction);
    }
    return balance;
  }

  Balance caluculateExpensesPerDay(
    List<Transaction> items,
    CurrencyProvider currencyProvider,
  ) {
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

  void fromJson(String? jsonString, bool append) {
    if (jsonString != null) {
      if (!append) clear();
      final jsonList = jsonDecode(jsonString) as List;
      for (var json in jsonList) {
        add(Transaction.fromJson(json), notify: false);
      }
      notifyListeners();
    }
  }
}
