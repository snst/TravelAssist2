import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelassist2/widgets/widget_multi_line_input.dart';

import '../currency/currency.dart';
import '../currency/currency_chooser_widget.dart';
import '../currency/currency_provider.dart';
import '../utils/globals.dart';
import '../utils/map.dart';
import '../utils/travel_assist_utils.dart';
import '../widgets/widget_combobox.dart';
import '../widgets/widget_date_chooser.dart';
import '../widgets/widget_item_edit_actions.dart';
import 'transaction.dart';
import 'transaction_provider.dart';
import 'transaction_value.dart';

class TransactionItemPage extends StatefulWidget {
  TransactionItemPage({super.key, this.item, this.category})
    : newItem = item == null,
      modifiedItem = item == null
          ? Transaction(date: DateTime.now(), currency: "", method: "")
          : item.clone();

  final bool newItem;
  final Transaction? item;
  final Transaction modifiedItem;
  final String? category;

  @override
  State<TransactionItemPage> createState() => _TransactionItemPageState();
}

class _TransactionItemPageState extends State<TransactionItemPage> {
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController paymentMethodController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStoredValue();
    if (widget.newItem) {
      _getGpsPos();
      widget.modifiedItem.category = widget.category ?? "";
    }
    _amountController.text = widget.modifiedItem.value == 0
        ? ""
        : widget.modifiedItem.valueString;
  }

  @override
  void dispose() {
    categoryController.dispose();
    paymentMethodController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String defaultCurrency = "";

  Future<void> _getGpsPos() async {
    Position position = await getPosition();
    widget.modifiedItem.latitude = position.latitude;
    widget.modifiedItem.longitude = position.longitude;
  }

  Future<void> _loadStoredValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    defaultCurrency = prefs.getString('defaultCurreny') ?? "€";
    setState(() {
      if (widget.modifiedItem.currency == "") {
        widget.modifiedItem.currency = defaultCurrency;
      }
    });
  }

  void _saveStoredValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('defaultCurreny', defaultCurrency);
  }

  bool save(
    List<Transaction> items,
    TransactionProvider transactionProvider,
    CurrencyProvider currencyProvider,
  ) {
    switch (widget.modifiedItem.type) {
      case TransactionTypeEnum.cashCorrection:
        Currency? currency = currencyProvider.getCurrencyByName(
          widget.modifiedItem.currency,
        );
        TransactionValue cash = transactionProvider.calcCurrentCash(
          items,
          currencyProvider,
          currency,
        );
        double difference = widget.modifiedItem.value - cash.value;
        widget.modifiedItem.name = widget.modifiedItem.valueCurrencyString;
        widget.modifiedItem.value = difference;
        widget.modifiedItem.method = "";
        break;
      default:
        widget.modifiedItem.category = categoryController.text;
        widget.modifiedItem.method = paymentMethodController.text;
        break;
    }

    (widget.item ?? widget.modifiedItem).update(widget.modifiedItem);
    transactionProvider.add(widget.item ?? widget.modifiedItem);

    if (widget.modifiedItem.currency != defaultCurrency) {
      defaultCurrency = widget.modifiedItem.currency;
      _saveStoredValues();
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TransactionProvider>();
    final cp = context.watch<CurrencyProvider>();

    return FutureBuilder(
      future: tp.getAll(),
      builder: (context, asyncSnapshot) {
        List<Transaction> items = asyncSnapshot.data ?? [];
        if (widget.modifiedItem.method == "") {
          final paymentMethodList = tp.getPaymentMethodList(items, false);
          if (paymentMethodList.isNotEmpty) {
            widget.modifiedItem.method = paymentMethodList[0];
          }
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(Txt.transaction),
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                children: <Widget>[
                  widgetAmountInput(cp),
                  const SizedBox(height: 5),

                  if (widget.modifiedItem.type ==
                      TransactionTypeEnum.expense) ...[
                    WidgetComboBox(
                      controller: categoryController,
                      selectedText: widget.modifiedItem.category,
                      hintText: Txt.category,
                      filter: true,
                      onChanged: (p0) {
                        setState(() {
                          widget.modifiedItem.category = p0;
                        });
                      },
                      items: tp.getCategoryList(items),
                    ),
                    const SizedBox(height: 5),
                  ],
                  Row(
                    children: [
                      SizedBox(
                        width: 135,
                        child: Container(
                          decoration: BorderStyles.box,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: DropdownButton(
                              value: widget.modifiedItem.type,
                              isExpanded: true,
                              underline: SizedBox(),
                              items: const [
                                DropdownMenuItem(
                                  value: TransactionTypeEnum.expense,
                                  child: Text("Expense"),
                                ),
                                DropdownMenuItem(
                                  value: TransactionTypeEnum.withdrawal,
                                  child: Text("Withdrawal"),
                                ),
                                DropdownMenuItem(
                                  value: TransactionTypeEnum.cashCorrection,
                                  child: Text("Cash Count"),
                                ),
                                DropdownMenuItem(
                                  value: TransactionTypeEnum.deposit,
                                  child: Text("Deposit"),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  widget.modifiedItem.type = value!;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      if (widget.modifiedItem.type ==
                              TransactionTypeEnum.expense ||
                          widget.modifiedItem.type ==
                              TransactionTypeEnum.withdrawal) ...[
                        Expanded(
                          child: WidgetComboBox(
                            controller: paymentMethodController,
                            selectedText: widget.modifiedItem.method,
                            hintText: '',
                            filter: false,
                            onChanged: (p0) {
                              setState(() {
                                widget.modifiedItem.method = p0;
                              });
                            },
                            items: tp.getPaymentMethodList(
                              items,
                              widget.modifiedItem.type ==
                                  TransactionTypeEnum.withdrawal,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: WidgetMultiLineInput(
                      onChanged: (value) {
                        setState(() {
                          widget.modifiedItem.name = value;
                        });
                      },
                      initalText: widget.modifiedItem.name,
                      hintText: Txt.comment,
                      lines: 2,
                    ),
                  ),

                  if (widget.modifiedItem.type ==
                      TransactionTypeEnum.expense) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          ElevatedButton(
                            child: const Text('Map'),
                            onPressed: () {
                              launchMapOnAndroid(
                                widget.modifiedItem.latitude,
                                widget.modifiedItem.longitude,
                              );
                            },
                          ),
                          Spacer(),
                          WidgetDateChooser(
                            date: widget.modifiedItem.date,
                            onChanged: (val) => setState(() {
                              widget.modifiedItem.date = val;
                            }),
                          ),
                          const Spacer(),
                          SpinBox(
                            value: widget.modifiedItem.averageDays.toDouble(),
                            decoration: const InputDecoration(
                              constraints: BoxConstraints.tightFor(width: 170),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 11,
                              ),
                              labelText: 'Average Days',
                            ),
                            onChanged: (value) =>
                                widget.modifiedItem.averageDays = value.toInt(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                  //widgetButtons(transactionProvider, currencyProvider),
                  WidgetItemEditActions(
                    onSave: () {
                      return save(items, tp, cp);
                    },
                    onDelete: (widget.newItem)
                        ? null
                        : () {
                            tp.delete(widget.item!);
                          },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Row widgetAmountInput(CurrencyProvider currencyProvider) {
    return Row(
      children: [
        Flexible(
          child: TextField(
            textAlign: TextAlign.right,
            controller: _amountController,
            decoration: InputDecoration(
              hintText: "Amount",
              border: BorderStyles.input,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
            ),
            onChanged: (value) {
              widget.modifiedItem.value = safeConvertToDouble(value);
            },
            autofocus: widget.newItem,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
            autocorrect: false,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
            ],
          ),
        ),
        const SizedBox(width: 8,),
        CurrencyChooserWidget(
          currencies: currencyProvider.getVisibleItemsWith(
            currencyProvider.getCurrencyFromTransaction(widget.modifiedItem),
          ),
          selected: currencyProvider.getCurrencyFromTransaction(
            widget.modifiedItem,
          ),
          onChanged: (currency) {
            setState(() {
              widget.modifiedItem.currency = currency.name;
            });
          },
        ),
      ],
    );
  }

}
