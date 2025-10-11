import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'currency/currency_list_page.dart';
import 'currency/currency_provider.dart';
import 'calculator/calculator_page.dart';
import 'calculator/calculator.dart';
import 'location_list/location_list_page.dart';
import 'location_list/location_provider.dart';
import 'location_list/location_item_page.dart';
import 'todo_list/todo_list_page.dart';
import 'todo_list/todo_provider.dart';
import 'transaction_list/transaction_main_page.dart';
import 'transaction_list/transaction_provider.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Info')),
      body: const Center(child: Text('Info Page')),
    );
  }
}

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: const Center(child: Text('Expenses Page')),
    );
  }
}

// A class to hold the button data
class ActionButton {
  final String label;
  final Widget page;

  ActionButton({required this.label, required this.page});
}

void main() {
  //runApp(const MyApp());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TodoProvider()),
        ChangeNotifierProvider(create: (context) => CurrencyProvider()),
        ChangeNotifierProvider(create: (context) => TransactionProvider()),
        ChangeNotifierProvider(create: (context) => LocationProvider()),
        ChangeNotifierProvider(create: (context) => Calculator()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TravelAssist',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(title: 'TravelAssist'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Define the list of buttons and their corresponding pages
  final List<ActionButton> _buttons = [
    ActionButton(label: 'Calculator', page: const CalculatorPage()),
    ActionButton(label: 'Add Location', page: LocationItemPage()),
    ActionButton(label: 'Locations', page: const LocationListPage()),
    ActionButton(label: 'To-Do', page: const TodoListPage()),
    ActionButton(label: 'Transactions', page: const TransactionMainPage()),
    ActionButton(label: 'infos', page: const ExpensesPage()),
    ActionButton(label: 'info', page: const InfoPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              //const PopupMenuItem(value: 0, child: Text("Currency rates")),
              const PopupMenuItem(value: 1, child: Text("Currency rates")),
            ],
            elevation: 1,
            onSelected: (value) {
              switch (value) {
                case 1:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CurrencyListPage()),
                  );
                  break;
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 buttons per row
            crossAxisSpacing: 8.0, // Spacing between columns
            mainAxisSpacing: 8.0, // Spacing between rows
          ),
          itemCount: _buttons.length,
          itemBuilder: (context, index) {
            final button = _buttons[index];
            return ElevatedButton(
              onPressed: () {
                // Navigate to the new page when a button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => button.page),
                );
              },
              child: Text(button.label, textAlign: TextAlign.center),
            );
          },
        ),
      ),
    );
  }
}
