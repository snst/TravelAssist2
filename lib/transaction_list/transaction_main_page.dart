import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../currency/currency.dart';
import '../currency/currency_provider.dart';
//import 'currency_rates_page.dart';
//import '../widgets/drawer_widget.dart';
import 'transaction_balance_subpage.dart';
import 'transaction_list_subpage.dart';
import 'transaction_provider.dart';
import 'transaction_edit_page.dart';
import 'transaction.dart';
import '../widgets/export_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TransactionMainPage extends StatefulWidget {
  const TransactionMainPage({super.key});
  static int pageIndex = 0;
  //final DrawerWidget drawer;
  @override
  State<TransactionMainPage> createState() => _TransactionMainPageState();
}

class _TransactionMainPageState extends State<TransactionMainPage> {
  Currency? shownCurrency;
  int _selectedSubPageIndex = 0;
  Future<void> _showEditDialog(Transaction item) async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TransactionEditPage(
                newItem: false,
                item: item,
              )),
    );
  }

/*
  void showCurrenyRatesPage(
      BuildContext context, CurrencyProvider currencyProvider) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Scaffold(
          appBar: AppBar(
            title: const Text("Currency rates"),
          ),
          body: CurrencyRatesPage(currencyProvider: currencyProvider));
    }));
  }*/


  void showCurrencySettingsPage(BuildContext context, TransactionProvider tp) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Scaffold(
          appBar: AppBar(
            title: const Text("Settings"),
          ),
          body: ExportWidget(
            name: 'transaction',
            toJson: tp.toJson,
            fromJson: tp.fromJson,
            clearJson: tp.clear,
          ));
    }));
  }

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CurrencyProvider>();
    final tp = context.watch<TransactionProvider>();
    shownCurrency ??= cp.getHomeCurrency();

    if (null == shownCurrency) {
      return const CircularProgressIndicator();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expenses"),
        actions: [
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              //const PopupMenuItem(value: 0, child: Text("Currency rates")),
              const PopupMenuItem(value: 1, child: Text("Settings")),
            ],
            elevation: 1,
            onSelected: (value) {
              switch (value) {
                //case 0:
                //  showCurrenyRatesPage(context, cp);
                //  break;
                case 1:
                  showCurrencySettingsPage(context, tp);
                  break;
              }
            },
          ),
        ],
      ),
      body: () {
        if (_selectedSubPageIndex == 1) {
          return TransactionBalanceSubPage(
              transactionProvider: tp, currencyProvider: cp);
        } else {
          return TransactionListSubpage(onShowEditDialog: _showEditDialog);
        }
      }(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TransactionEditPage(
                      newItem: true,
                      item: Transaction(date: DateTime.now(), currency: "", method: ""), 
                    )),
          );
        },
        tooltip: 'Add item',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.list),
            label: 'Entries',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.squarePollHorizontal),
            label: 'Statistics',
          ),
        ],
        currentIndex: _selectedSubPageIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (index) {
          setState(() {
            _selectedSubPageIndex = index;
          });
        },
      ),
    );
  }
}
