import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../currency/currency.dart';
import '../currency/currency_provider.dart';
import '../currency/currency_value.dart';
import '../utils/globals.dart';
import '../utils/travel_assist_utils.dart';
import 'calculator.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  List<TextEditingController>? controllers;

  List<FocusNode>? focusNodes;

  double _currentValue = 0;

  Currency? _currentCurrency;

  Calculator? calculator;

  final ScrollController _scrollController = ScrollController();

  void onChanged(int index, String text, CurrencyProvider cp) {
    if (controllers != null) {
      double val = safeConvertToDouble(text);
      _currentValue = val;
      _currentCurrency = cp.visibleItems[index];
      for (int j = 0; j < controllers!.length; j++) {
        if (j != index) {
          controllers![j].text = cp.visibleItems[index].convertToString(
            val,
            cp.visibleItems[j],
          );
        }
      }
    }
  }

  void clearAllInputs() {
    if (controllers != null) {
      for (final controller in controllers!) {
        controller.clear();
      }
    }
  }

  void pushValue() {
    if (_currentCurrency != null) {
      calculator?.pushValue(CurrencyValue(_currentValue, _currentCurrency));
    }
    clearAllInputs();
    _currentCurrency = null;
  }

  void _scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onCalculatorUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();

    calculator ??= context.watch<Calculator>();

    if (controllers == null ||
        controllers!.length != currencyProvider.visibleItems.length) {
      controllers = List.generate(
        currencyProvider.visibleItems.length,
        (index) => TextEditingController(),
      );
      focusNodes = List.generate(
        currencyProvider.visibleItems.length,
        (index) => FocusNode(),
      );
    }

    if (calculator!.showResult()) {
      for (int j = 0; j < currencyProvider.visibleItems.length; j++) {
        controllers?[j].text = calculator!.sum
            .convertTo(currencyProvider.visibleItems[j])
            .valueString;
      }
    }

    const buttonStyle = TextStyle(fontSize: 30);
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text(Txt.calculator)),
      body: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: currencyProvider.visibleItems.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(30, 13, 30, 2),
                child: TextFormField(
                  controller: controllers![index],
                  focusNode: focusNodes![index],
                  onChanged: (text) {
                    onChanged(index, text, currencyProvider);
                  },
                  style: const TextStyle(
                    fontSize: 18,
                    //color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                  autocorrect: false,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                  ],
                  decoration: InputDecoration(
                    border: BorderStyles.input,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    labelText: currencyProvider.visibleItems[index].name,
                    labelStyle: const TextStyle(fontSize: 26),
                    suffixIcon: IconButton(
                      onPressed: () {
                        controllers![index].clear();
                        focusNodes![index].requestFocus();
                      },
                      icon: const Icon(Icons.clear),
                    ),
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                child: Text(
                  calculator!.inputString,
                  style: const TextStyle(fontSize: 20),
                  maxLines: 1,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                calculator!.sum.toString(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                child: ElevatedButton(
                  onLongPress: () {
                    calculator?.clear();
                    clearAllInputs();
                  },
                  onPressed: () {
                    _onCalculatorUpdate();
                    calculator?.back();
                    clearAllInputs();
                  },
                  child: const Icon(Icons.backspace,
                      size: 30),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: ElevatedButton(
                  onPressed: () {
                    _onCalculatorUpdate();
                    pushValue();
                    calculator?.add();
                  },
                  child: const Text(
                      "+", style: buttonStyle),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: ElevatedButton(
                  onPressed: () {
                    _onCalculatorUpdate();
                    pushValue();
                    calculator?.subtract();
                  },
                  child: const Text("-", style: buttonStyle),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: ElevatedButton(
                  onPressed: () {
                    _onCalculatorUpdate();
                    pushValue();
                    calculator?.calculate();
                  },
                  child: const Text("=", style: buttonStyle),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
