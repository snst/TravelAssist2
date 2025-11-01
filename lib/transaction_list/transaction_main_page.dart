import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../currency/currency.dart';
import '../currency/currency_provider.dart';
import '../utils/globals.dart';
import 'transaction.dart';
import 'transaction_balance_subpage.dart';
import 'transaction_item_page.dart';
import 'transaction_list_subpage.dart';

class TransactionMainPage extends StatefulWidget {
  const TransactionMainPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();
    shownCurrency ??= currencyProvider.getHomeCurrency();

    if (null == shownCurrency) {
      return const CircularProgressIndicator();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(Txt.expenses),
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
