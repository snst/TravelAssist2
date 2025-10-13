import 'package:isar_community/isar.dart';
import '../currency/currency.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';
part 'transaction.g.dart';

// flutter packages pub run build_runner build

enum TransactionTypeEnum {
  expense,
  withdrawal,
  cashCorrection,
  deposit;
}

@collection
@JsonSerializable()
class Transaction {
  Transaction(
      {this.name = "",
      this.value = 0.0,
      this.currency = "",
      this.type = TransactionTypeEnum.expense,
      required this.date,
      this.category = "",
      this.averageDays = 1,
      this.method = "",
      this.latitude=0,
      this.longitude=0});

  @JsonKey(includeFromJson: false, includeToJson: false)
  Id id = Isar.autoIncrement;
  String name;
  String category;
  String method;
  double value;
  String currency;
  DateTime date;
  int averageDays;
  @enumerated
  TransactionTypeEnum type;
  double latitude;
  double longitude;

  @override
  String toString() {
    return "$date $type: $value $currency $name";
  }

  @ignore
  bool get isCash => method.isEmpty || method == "Cash";

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
        hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  }

  String getCategoryNameStr() {
    switch (type) {
      case TransactionTypeEnum.withdrawal:
        return "Withdrawal $name";
      case TransactionTypeEnum.deposit:
        return "Deposit $name";
      case TransactionTypeEnum.cashCorrection:
        return "Cash Count $name";
      default:
        return "$category $name";
    }
  }

  void update(Transaction other) {
    name = other.name;
    value = other.value;
    type = other.type;
    date = other.date;
    category = other.category;
    currency = other.currency;
    averageDays = other.averageDays;
    method = other.method;
    longitude = other.longitude;
    latitude = other.latitude;
  }

  Transaction clone() {
    var item = Transaction(date: date);
    item.update(this);
    return item;
  }

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}
