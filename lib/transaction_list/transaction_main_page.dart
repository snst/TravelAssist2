import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../currency/currency.dart';
import '../currency/currency_provider.dart';
import '../utils/globals.dart';
import '../widgets/export_widget.dart';
import 'transaction.dart';
//import 'currency_rates_page.dart';
//import '../widgets/drawer_widget.dart';
import 'transaction_balance_subpage.dart';
import 'transaction_item_page.dart';
import 'transaction_list_subpage.dart';
import 'transaction_provider.dart';

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
      MaterialPageRoute(builder: (context) => TransactionItemPage(item: item)),
    );
  }

  void showCurrencyImportExportPage(BuildContext context, TransactionProvider tp) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: const Text(Txt.importExport)),
            body: ExportWidget(
              name: 'transaction',
              toJson: tp.toJson,
              fromJson: tp.fromJson,
              clearJson: tp.clear,
            ),
          );
        },
      ),
    );
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Expenses"),
        actions: [
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              const PopupMenuItem(value: 0, child: Text(Txt.importExport)),
            ],
            elevation: 1,
            onSelected: (value) {
              switch (value) {
                case 0:
                  showCurrencyImportExportPage(context, tp);
                  break;
              }
            },
          ),
        ],
      ),
      body: () {
        if (_selectedSubPageIndex == 1) {
          return TransactionBalanceSubPage();
        } else {
          return TransactionListSubpage(onShowEditDialog: _showEditDialog);
        }
      }(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TransactionItemPage()),
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
