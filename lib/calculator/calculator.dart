import 'package:flutter/material.dart';

import '../currency/currency_value.dart';

class CalculatorOp {
  CalculatorOp({this.value, this.op = ""});

  CurrencyValue? value;
  String op;

  @override
  String toString() {
    return value != null ? value!.toShortString() : " $op ";
  }

  bool isResult() {
    return op == "=";
  }
}

class Calculator extends ChangeNotifier {
  final List<CalculatorOp> _operations = [];
  String inputString = "";
  String resultString = "dd";
  CurrencyValue sum = CurrencyValue(0, null);

  void update() {
    inputString = "";
    sum.reset();
    String lastOp = "+";
    for (final operation in _operations) {
      inputString += operation.toString();
      if (operation.value != null) {
        switch (lastOp) {
          case "+":
          case "=":
            sum.add(operation.value);
            break;
          case "-":
            sum.sub(operation.value);
            break;
          default:
            break;
        }
      } else {
        lastOp = operation.op;
      }
    }
    //print("$inputString = ${sum.toString()}");
    notifyListeners();
  }

  void pushValue(CurrencyValue val) {
    if (_operations.isEmpty || _operations.last.op.isNotEmpty) {
      if (_operations.isNotEmpty &&
          _operations.last.op.isNotEmpty &&
          _operations.last.op == "=") {
        _operations.last.op = "+";
      }
      _operations.add(CalculatorOp(value: val));
    }
  }

  void subtract() {
    addOperation("-");
  }

  void add() {
    addOperation("+");
  }

  void back() {
    if (_operations.isNotEmpty) {
      _operations.removeLast();
      update();
    }
  }

  void clear() {
    _operations.clear();
    update();
  }

  void addOperation(String op) {
    if (_operations.isNotEmpty) {
      if (_operations.last.op.isNotEmpty) {
        _operations.removeLast();
      }
      _operations.add(CalculatorOp(op: op));
    }
    update();
  }

  void calculate() {
    addOperation("=");
  }

  bool showResult() {
    return _operations.isNotEmpty && _operations.last.isResult();
  }
}
