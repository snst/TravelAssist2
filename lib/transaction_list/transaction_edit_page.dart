import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/globals.dart';
import '../currency/currency.dart';
import 'transaction_provider.dart';
import 'transaction_value.dart';
import '../widgets/widget_combobox.dart';
import '../widgets/widget_date_chooser.dart';
import '../widgets/widget_transaction_description_input.dart';
import 'transaction.dart';
import '../currency/currency_provider.dart';
import '../utils/travel_assist_utils.dart';
import '../currency/currency_chooser_widget.dart';
import 'package:flutter_spinbox/material.dart';
import '../utils/map.dart';
import 'package:geolocator/geolocator.dart';

class TransactionEditPage extends StatefulWidget {
  TransactionEditPage({
    super.key,
    this.item,
    this.category,
  })  : newItem = item == null,
        modifiedItem = (item ?? Transaction(date: DateTime.now(), currency: "", method: "")).clone();

  final bool newItem;
  final Transaction? item;
  final Transaction modifiedItem;
  final String? category;


  @override
  State<TransactionEditPage> createState() => _TransactionEditPageState();
}

class _TransactionEditPageState extends State<TransactionEditPage> {
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController paymentMethodController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStoredValue();
    if (widget.newItem) {
      _getGpsPos();
      widget.modifiedItem.category = widget.category ?? "";
    }
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

  void saveAndClose(BuildContext context) {
    final tp = TransactionProvider.getInstance(context);

    switch (widget.modifiedItem.type) {
      case TransactionTypeEnum.cashCorrection:
        CurrencyProvider cp = CurrencyProvider.getInstance(context);
        Currency? currency = cp.getCurrencyByName(widget.modifiedItem.currency);
        TransactionValue cash = tp.calcCurrentCash(cp, currency);
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
    tp.add(widget.item ?? widget.modifiedItem);

    if (widget.modifiedItem.currency != defaultCurrency) {
      defaultCurrency = widget.modifiedItem.currency;
      _saveStoredValues();
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    CurrencyProvider currencyProvider = CurrencyProvider.getInstance(context);

    if (widget.modifiedItem.method == "") {
      final paymentMethodList =
          TransactionProvider.getInstance(context).getPaymentMethodList(false);
      if (paymentMethodList.isNotEmpty) {
        widget.modifiedItem.method = paymentMethodList[0];
      }
    }

    return Scaffold(
      appBar: AppBar(
          //automaticallyImplyLeading: false,
          title: widgetAmountInput(currencyProvider)),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: SingleChildScrollView(
          reverse: true,
          child: Column(
            children: <Widget>[
              if (widget.modifiedItem.type == TransactionTypeEnum.expense) ...[
                // CATEGORY
                WidgetComboBox(
                  controller: categoryController,
                  selectedText: widget.modifiedItem.category,
                  hintText: 'Category',
                  filter: true,
                  onChanged: (p0) {
                    setState(() {
                      widget.modifiedItem.category = p0;
                    });
                  },
                  items: TransactionProvider.getInstance(context)
                      .getCategoryList(),
                ),
              ],
              // DESCRIPTION
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: WidgetTransactionDescriptionInput(
                  widget: widget,
                  hintText: "Description",
                ),
              ),
              if (widget.modifiedItem.type == TransactionTypeEnum.expense)
                ...[],
              Row(
                children: [
                  SizedBox(
                    width: 135,
                    child: Container(
                      decoration: BorderStyles.box,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 3, 1, 3),
                        child: DropdownButton(
                          value: widget.modifiedItem.type,
                          isExpanded: true,
                          underline: SizedBox(),
                          // decoration: ,
                          items: const [
                            DropdownMenuItem(
                                value: TransactionTypeEnum.expense,
                                child: Text("Expense")),
                            DropdownMenuItem(
                                value: TransactionTypeEnum.withdrawal,
                                child: Text("Withdrawal")),
                            DropdownMenuItem(
                                value: TransactionTypeEnum.cashCorrection,
                                child: Text("Cash Count")),
                            DropdownMenuItem(
                                value: TransactionTypeEnum.deposit,
                                child: Text("Deposit")),
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
                  SizedBox(
                    width: 10,
                  ),
                  if (widget.modifiedItem.type == TransactionTypeEnum.expense ||
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
                        items: TransactionProvider.getInstance(context)
                            .getPaymentMethodList(widget.modifiedItem.type ==
                                TransactionTypeEnum.withdrawal),
                      ),
                    ),
                  ],
                ],
              ),

              if (widget.modifiedItem.type == TransactionTypeEnum.expense) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                  child: Row(
                    children: [
                      ElevatedButton(
                          child: const Text('Map'),
                          onPressed: () {
                            launchMapOnAndroid(
                                widget.modifiedItem.latitude, widget.modifiedItem.longitude);
                          }),
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
                            constraints: BoxConstraints.tightFor(
                              width: 170,
                            ),
                            labelText: 'Average Days'),
                        onChanged: (value) =>
                            widget.modifiedItem.averageDays = value.toInt(),
                      ),
                    ],
                  ),
                ),
              ],
              widgetButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Row widgetAmountInput(CurrencyProvider currencyProvider) {
    return Row(
      children: [
        Flexible(
          child: TextField(
            textAlign: TextAlign.right,
            controller: TextEditingController()
              ..text = widget.modifiedItem.value == 0
                  ? ""
                  : widget.modifiedItem.valueString,
            decoration: const InputDecoration(hintText: 'Amount'),
            onChanged: (value) {
              //modified = true;
              widget.modifiedItem.value = safeConvertToDouble(value);
            },
            autofocus: widget.newItem,
            style: const TextStyle(
              fontSize: 30,
              //color: Colors.blue.shade700,
              fontWeight: FontWeight.w600,
            ),
            autocorrect: false,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
            ],
          ),
        ),
        CurrencyChooserWidget(
            currencies: currencyProvider.getVisibleItemsWith(currencyProvider
                .getCurrencyFromTransaction(widget.modifiedItem)),
            selected: currencyProvider
                .getCurrencyFromTransaction(widget.modifiedItem),
            onChanged: (currency) {
              setState(() {
                widget.modifiedItem.currency = currency.name;
              });
            })
      ],
    );
  }

  Padding widgetButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(children: [
        /*WidgetDateChooser(
          date: widget.modifiedItem.date,
          onChanged: (val) => setState(() {
            widget.modifiedItem.date = val;
          }),
        ),*/

        const Spacer(),
        ElevatedButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        if (!widget.newItem)
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 0, 0),
            child:         ElevatedButton(
                child: const Text('Delete'),
                onPressed: () {
                  TransactionProvider.getInstance(context).delete(widget.item!);
                  Navigator.of(context).pop();
                }),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 0, 0),
          child:         ElevatedButton(
              child: const Text('Save'),
              //alignment: Alignment.centerRight,
              onPressed: () {
                saveAndClose(context);
              }),
        ),
      ]),
    );
  }
}
