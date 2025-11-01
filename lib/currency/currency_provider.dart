import 'dart:collection';

import 'package:isar_community/isar.dart';

import '../transaction_list/transaction.dart';
import '../transaction_list/transaction_value.dart';
import '../utils/storage.dart';
import 'currency.dart';

class CurrencyProvider extends Storage<Currency>  {

  CurrencyProvider(super.isar) {
    init();
  }

  final HashMap<String, Currency> _currencyMap = HashMap();

  List<Currency> get allItems => _currencyMap.values.toList();

  List<Currency> get visibleItems => allItems
      .where((element) => element.state != CurrencyStateEnum.hide)
      .toList();

  List<Currency> getVisibleItemsWith(Currency? currency) {
    var list = allItems
        .where((element) => element.state != CurrencyStateEnum.hide)
        .toList();
    if (currency != null) {
      if (!list.contains(currency)) {
        list.insert(0, currency);
      }
    }
    return list;
  }

  Currency? _homeCurrency;

  void init() async {
    isar.txn(() async {
      final currencyList = await isar.currencys.where().findAll();
      for (final currency in currencyList) {
        _currencyMap[currency.name] = currency;
      }
      updateHomeCurrency(null);
      notifyListeners();
    });
  }

  void updateHomeCurrency(Currency? currency) {
    if (currency?.state == CurrencyStateEnum.home) {
      for (var iter in _currencyMap.values) {
        if (iter.state == CurrencyStateEnum.home && iter != currency) {
          iter.state = CurrencyStateEnum.show;
        }
      }
    }
    _homeCurrency = null;
    for (var iter in _currencyMap.values) {
      if (iter.state == CurrencyStateEnum.home) {
        _homeCurrency = iter;
      }
    }
    _homeCurrency ??= _currencyMap.values.firstOrNull;
    _homeCurrency?.state = CurrencyStateEnum.home;
  }

  @override
  Future<void> add(Currency item, {bool notify = true}) async {
    updateHomeCurrency(item);
    _currencyMap[item.name] = item;
    _currencyMap.removeWhere((key, value) => value == item);
    super.add(item);
  }

  @override
  Future<void> delete(Currency item) async {
    _currencyMap.removeWhere((key, value) => value == item);
    super.delete(item);
  }

  Currency? getHomeCurrency() {
    return _homeCurrency;
  }

  Currency? getCurrencyByName(String name) {
    return _currencyMap.containsKey(name) ? _currencyMap[name] : null;
  }


  TransactionValue getTransactionValue(Transaction transaction) {
    var currency = getCurrencyByName(transaction.currency);
    return TransactionValue(transaction.value, currency);
  }

  TransactionValue convertTo(Transaction transaction, Currency? to) {
    return getTransactionValue(transaction).convertTo(to);
  }

  Currency? getCurrencyFromTransaction(Transaction transaction) {
    return getCurrencyByName(transaction.currency);
  }
}
