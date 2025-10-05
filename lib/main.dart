import 'package:flutter/material.dart';
import 'package:travelassist2/currency/currency_rates_page.dart';


class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculator')),
      body: const Center(child: Text('Calculator Page')),
    );
  }
}

class PosPage extends StatelessWidget {
  const PosPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('POS')),
      body: const Center(child: Text('POS Page')),
    );
  }
}

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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
    ActionButton(label: 'currencies', page: const CurrencyRatesPage()),
    ActionButton(label: 'calculator', page: const CalculatorPage()),
    ActionButton(label: 'pos', page: const PosPage()),
    ActionButton(label: 'info', page: const InfoPage()),
    ActionButton(label: 'expenses', page: const ExpensesPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
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
              child: Text(
                button.label,
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ),
    );
  }
}
