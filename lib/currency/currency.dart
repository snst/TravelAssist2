//import 'package:isar/isar.dart';
import 'package:isar_community/isar.dart';

// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';

import '../utils/storage_item.dart';
part 'currency.g.dart';

enum CurrencyStateEnum {
  home,
  show,
  hide;
}

@collection
@JsonSerializable()
class Currency implements StorageItem {
  Currency(
      {this.name = "", this.value = 1.0, this.state = CurrencyStateEnum.show});

  @JsonKey(includeFromJson: false, includeToJson: false)
  Id id = Isar.autoIncrement;
  String name;
  double value;
  @enumerated
  CurrencyStateEnum state;

  double convertTo(double value, Currency? to) {
    return to != null && this != to ? Currency.convert(value, this, to) : value;
  }

  static double convert(double value, Currency? from, Currency? to) {
    if (from == null || to == null) {
      return value;
    } else {
      return value / from.value * to.value;
    }
  }

  String convertToString(double value, Currency? to) {
    return Currency.formatValue(Currency.convert(value, this, to));
  }

  @override
  String toString() => name;

  static String formatValue(double value) => value.toStringAsFixed(2);

  static String roundToString(double value) => value.round().toString();


  static String formatValueCurrency(double value, String currency) =>
      "${Currency.formatValue(value)} $currency";

  factory Currency.fromJson(Map<String, dynamic> json) =>
      _$CurrencyFromJson(json);

  Map<String, dynamic> toJson() => _$CurrencyToJson(this);

  @override
  Id getId() {
    return id;
  }
}
