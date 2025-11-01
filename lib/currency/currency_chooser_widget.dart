import 'package:flutter/material.dart';

import 'currency.dart';

class CurrencyChooserWidget extends StatelessWidget {
  const CurrencyChooserWidget({
    super.key,
    required this.currencies,
    required this.selected,
    required this.onChanged,
  });

  final List<Currency> currencies;
  final Currency? selected;
  final void Function(Currency currency) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButton<Currency>(
        value: selected,
        underline: Container(), // Remove the default underline
        onChanged: (currency) => onChanged(currency!),
        items: currencies.map<DropdownMenuItem<Currency>>((Currency value) {
          return DropdownMenuItem<Currency>(
            value: value,
            child: Text(value.toString(), style: TextStyle(fontSize: 24)),
          );
        }).toList(),
      ),
    );
  }
}
