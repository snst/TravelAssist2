import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';

import '../currency/currency.dart';
import '../utils/globals.dart';
import '../utils/storage_item.dart';

part 'transaction.g.dart';

// flutter packages pub run build_runner build

enum TransactionTypeEnum { expense, withdrawal, cashCorrection, deposit }

@collection
@JsonSerializable()
class Transaction implements StorageItem {
  Transaction({
    this.comment = "",
    this.value = 0.0,
    this.currency = "",
    this.type = TransactionTypeEnum.expense,
    required this.date,
    this.averageDays = 1,
    this.method = "",
    this.latitude = 0,
    this.longitude = 0,
    this.tags = const [],
  });

  @JsonKey(includeFromJson: false, includeToJson: false)
  Id id = Isar.autoIncrement;
  String comment;
  String method;
  double value;
  String currency;
  DateTime date;
  int averageDays;
  @enumerated
  TransactionTypeEnum type;
  double latitude;
  double longitude;
  List<String> tags;

  @ignore
  bool get isCash => method.isEmpty || method == Txt.cash;

  @ignore
  bool get isWithdrawal => type == TransactionTypeEnum.withdrawal;

  @ignore
  bool get isExpense => type == TransactionTypeEnum.expense;

  @ignore
  bool get isCashCorrection => type == TransactionTypeEnum.cashCorrection;

  @ignore
  bool get isCashDeposit => type == TransactionTypeEnum.deposit;

  @ignore
  String get dateString => DateFormat('EEEE, d MMMM y').format(date);

  @ignore
  String get valueString => Currency.formatValue(value);

  @ignore
  String get currencyString => currency.toString();

  @ignore
  String get valueCurrencyString =>
      Currency.formatValueCurrency(value, currency);

  @ignore
  DateTime get groupDate {
    return date.copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
  }

  String get tagStr {
    return tags.map((t) => '#$t').join(' ');
  }

  String getEntryStr() {
    switch (type) {
      case TransactionTypeEnum.withdrawal:
        return "Withdrawal";
      case TransactionTypeEnum.deposit:
        return "Deposit";
      case TransactionTypeEnum.cashCorrection:
        return "Cash Count";
      default:
        return tagStr;
    }
  }

  void update(Transaction other) {
    comment = other.comment;
    value = other.value;
    type = other.type;
    date = other.date;
    currency = other.currency;
    averageDays = other.averageDays;
    method = other.method;
    longitude = other.longitude;
    latitude = other.latitude;
    tags = other.tags.toList();
  }

  Transaction clone() {
    var item = Transaction(date: date);
    item.update(this);
    return item;
  }

  @override
  Id getId() {
    return id;
  }

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}
