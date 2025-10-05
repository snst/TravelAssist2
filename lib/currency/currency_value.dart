import 'currency.dart';
import '../utils/travel_assist_utils.dart';

class CurrencyValue {
  CurrencyValue(this.value, this.currency);
  double value;
  Currency? currency;

  String get valueString => Currency.formatValue(value);
  String get currencyString => currency != null ? currency.toString() : "?";
  @override
  String toString() => "$valueString $currencyString";
  String toShortString() => "${removeTrailingZeros(valueString)}$currencyString";
  bool isZero() => value == 0;
  String roundToString() => "${Currency.roundToString(value)} $currencyString";


  void reset() {
    value = 0;
    currency = null;
  }

  CurrencyValue convertTo(Currency? toCurrency) {
    if (currency == toCurrency || null == currency) {
      return this;
    } else {
      return CurrencyValue(
          currency!.convertTo(value, toCurrency), toCurrency);
    }
  }

  CurrencyValue operator +(CurrencyValue other) {
    currency ??= other.currency;
    double sum = value + other.convertTo(currency).value;
    return CurrencyValue(sum, currency);
  }

  CurrencyValue operator -(CurrencyValue other) {
    currency ??= other.currency;
    double sum = value - other.convertTo(currency).value;
    return CurrencyValue(sum, currency);
  }

  void add(CurrencyValue? other) {
    if (other != null) {
      currency ??= other.currency;
      value += other.convertTo(currency).value;
    }
  }

  void sub(CurrencyValue? other) {
    if (other != null) {
      currency ??= other.currency;
      value -= other.convertTo(currency).value;
    }
  }
}
