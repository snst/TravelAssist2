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
import 'transaction_list/transaction_edit_page.dart';
import 'transaction_list/transaction.dart';
import 'todo_list/todo_item_page.dart';
import 'todo_list/todo_item.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      //home: const MyHomePage(title: 'TravelAssist'),
      home: MainScreen(),

    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  void _onMainPressed(String title) {
    debugPrint('Main function pressed: $title');
  }

  void _onSubPressed(String title) {
    debugPrint('Sub function pressed: $title');
  }

  void _onShowPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double buttonHeight = 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Menu'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Calculator ---
            _buildMainButton(
              context,
              title: 'Calculator',
              icon: Icons.calculate,
              height: buttonHeight,
              onPressed: () => _onShowPage(context, const CalculatorPage()),
            ),
            const SizedBox(height: 16),
/*

    ActionButton(label: 'To-Do', page: const TodoListPage()),
    ActionButton(label: 'Transactions', page: const TransactionMainPage()),
    ActionButton(label: 'infos', page: const ExpensesPage()),
    ActionButton(label: 'info', page: const InfoPage()),
 */


            // --- Location List ---
            _buildMainButton(
              context,
              title: 'Locations',
              icon: Icons.map,
              height: buttonHeight,
              onPressed: () => _onShowPage(context, const LocationListPage()),
              onPressedSecondary: () => _onShowPage(context, LocationItemPage()),
            ),
            const SizedBox(height: 16),

            // --- Expenses ---
            _buildMainButton(
              context,
              title: 'Expenses',
              icon: Icons.attach_money,
              height: buttonHeight,
              onPressed: () => _onShowPage(context, const TransactionMainPage()),
              onPressedSecondary: () => _onShowPage(context, TransactionEditPage(
                newItem: true,
                item: Transaction(date: DateTime.now(), currency: "", method: ""),
              )),
            ),
            _buildScrollableSubfunctions(
              height: buttonHeight,
              subIcons: [
                {'icon': Icons.free_breakfast, 'name': 'Breakfast'},
                {'icon': Icons.lunch_dining, 'name': 'Lunch'},
                {'icon': Icons.dinner_dining, 'name': 'Dinner'},
                {'icon': Icons.local_cafe, 'name': 'Coffee'},
                {'icon': Icons.icecream, 'name': 'Dessert'},
                {'icon': Icons.local_pizza, 'name': 'Snack'},
              ],
              onSubPressed: _onSubPressed,
            ),
            const SizedBox(height: 8),

            // --- To-Do ---
            _buildMainButton(
              context,
              title: 'To-Dos',
              icon: Icons.list,
              height: buttonHeight,
              onPressed: () => _onShowPage(context, const TodoListPage()),
              onPressedSecondary: () => _onShowPage(context, TodoItemPage(
                newItem: true,
                item: TodoItem(quantity: 1),
              )),
            ),
            const SizedBox(height: 8),

          ],
        ),
      ),
    );
  }

  /// Main function button
  Widget _buildMainButton(
      BuildContext context, {
        required String title,
        required IconData icon,
        required double height,
        required VoidCallback onPressed,
        VoidCallback? onPressedSecondary,
      }) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: height,
            child: ElevatedButton.icon(
              icon: Icon(icon, size: 28),
              label: Text(title, style: const TextStyle(fontSize: 18)),

              onPressed: onPressed,
            ),
          ),
        ),
        if (onPressedSecondary != null)
          const SizedBox(width: 8),
        if (onPressedSecondary != null)
          SizedBox(
            height: height,
            width: height, // to make it square
            child: IconButton(
              iconSize: 32,
              icon: const Icon(Icons.add),

              onPressed: onPressedSecondary,
            ),
          ),
      ],
    );
  }

  /// Horizontally scrollable subfunction icons (below main button)
  Widget _buildScrollableSubfunctions({
    required double height,
    required List<Map<String, dynamic>> subIcons,
    required Function(String) onSubPressed,
  }) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: subIcons.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final sub = subIcons[index];
          return SizedBox(
            width: height, // square buttons
            height: height,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => onSubPressed(sub['name']),
              child: Icon(sub['icon'], size: 28),
            ),
          );
        },
      ),
    );
  }
}
/*
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  void _onMainPressed(String title) {
    debugPrint('Main function pressed: $title');
  }

  void _onSubPressed(String title) {
    debugPrint('Sub function pressed: $title');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Menu'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // --- Calculator ---
            _buildMainButton(
              context,
              title: 'Calculator',
              icon: Icons.calculate,
              onPressed: () => _onMainPressed('Calculator'),
            ),

            const SizedBox(height: 16),

            // --- Todo List ---
            _buildMainButton(
              context,
              title: 'Todo List',
              icon: Icons.check_circle_outline,
              onPressed: () => _onMainPressed('Todo List'),
            ),

            const SizedBox(height: 16),

            // --- Expenses (with subfunctions) ---
            _buildExpandableSection(
              context,
              title: 'Expenses',
              icon: Icons.attach_money,
              subFunctions: [
                {'title': 'Breakfast', 'icon': Icons.free_breakfast},
                {'title': 'Lunch', 'icon': Icons.lunch_dining},
                {'title': 'Dinner', 'icon': Icons.dinner_dining},
              ],
              onMainPressed: () => _onMainPressed('Expenses'),
              onSubPressed: _onSubPressed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainButton(BuildContext context,
      {required String title,
        required IconData icon,
        required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text(title, style: const TextStyle(fontSize: 18)),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildExpandableSection(
      BuildContext context, {
        required String title,
        required IconData icon,
        required List<Map<String, dynamic>> subFunctions,
        required VoidCallback onMainPressed,
        required Function(String) onSubPressed,
      }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
        children: subFunctions.map((sub) {
          return ListTile(
            leading: Icon(sub['icon']),
            title: Text(sub['title']),
            onTap: () => onSubPressed(sub['title']),
          );
        }).toList(),
      ),
    );
  }
}
*/

/*
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
*/
