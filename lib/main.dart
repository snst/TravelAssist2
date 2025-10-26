import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:travelassist2/todo_list/todo_item_page.dart';
import 'package:travelassist2/todo_list/todo_list_page.dart';
import 'package:travelassist2/utils/globals.dart';

import 'note_list/note.dart';
import 'note_list/note_item_page.dart';
import 'note_list/note_list_page.dart';
import 'note_list/note_provider.dart';
import 'calculator/calculator.dart';
import 'calculator/calculator_page.dart';
import 'currency/currency_list_page.dart';
import 'currency/currency_provider.dart';
import 'todo_list/todo_provider.dart';
import 'transaction_list/transaction_item_page.dart';
import 'transaction_list/transaction_main_page.dart';
import 'transaction_list/transaction_provider.dart';
import 'widgets/widget_dual_action_button.dart';
import 'providers/isar_service.dart';


void main() async {
    WidgetsFlutterBinding.ensureInitialized();

    final isarService = IsarService();
    await isarService.init();

  runApp(
    MultiProvider(
      providers: [
        //Provider<IsarService>.value(value: isarService),
        ChangeNotifierProvider(create: (context) => TodoProvider()),
        ChangeNotifierProvider(create: (context) => CurrencyProvider()),
        ChangeNotifierProvider(create: (context) => TransactionProvider()),
        ChangeNotifierProvider(create: (context) => Calculator()),
        ChangeNotifierProvider(create: (context) => NoteProvider(isarService.isar)),
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
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late StreamSubscription _intentSub;

  void handleSharedFile(SharedMediaFile file) async {
    final link = await moveSharedImageToDataFolder(file.path);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteItemPage(item: Note(link: link, tags:["link"])),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Access the provider here using `context.read` as the context is available.
    // We use `read` because we don't need to rebuild the widget when the provider changes.
    // Listen to media sharing coming from outside the app while the app is in the memory.
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      (value) {
        setState(() {
          handleSharedFile(value[0]);
        });
      },
      onError: (err) {
        //print("getIntentDataStream error: $err");
      },
    );

    // Get the media sharing coming from outside the app while the app is closed.
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      if (value.isNotEmpty) {
        setState(() {
          handleSharedFile(value[0]);

          // Tell the library that we are done processing the intent.
          ReceiveSharingIntent.instance.reset();
        });
      }
    });
  }

  @override
  void dispose() {
    _intentSub.cancel();
    super.dispose();
  }

  void _onShowPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Travel Assist"),
        actions: [
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              const PopupMenuItem(value: 1, child: Text("Currency rates")),
            ],
            elevation: 1,
            onSelected: (value) {
              switch (value) {
                case 1:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CurrencyListPage(),
                    ),
                  );
                  break;
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            WidgetDualActionButton(
              label: 'Calculator',
              icon: Icons.calculate,
              onMainPressed: () => _onShowPage(context, const CalculatorPage()),
            ),


            // --- To-Do ---
            WidgetDualActionButton(
              label: 'To-Dos',
              icon: Icons.list,
              onMainPressed: () => _onShowPage(context, const TodoListPage()),
              onAddPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TodoItemPage()),
                );
                if (result != null && context.mounted) {
                  _onShowPage(context, const TodoListPage());
                }
              },
            ),

            // --- To-Do ---
            WidgetDualActionButton(
              label: 'Lookup',
              icon: Icons.flash_on_sharp,
              onMainPressed: () => _onShowPage(context, NoteListPage(selectedTags:[Tags.lookup])),
              onAddPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NoteItemPage(item: Note(tags:[Tags.lookup]), newItem: true),
                  ),
                );
                if (result != null && context.mounted) {
                  _onShowPage(context, NoteListPage(selectedTags:[Tags.lookup]));
                }
              },
            ),


            WidgetDualActionButton(
              label: 'Locations',
              icon: Icons.map,
              onMainPressed: () =>
                  _onShowPage(context, NoteListPage(selectedTags:[Tags.loc])),
              onAddPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NoteItemPage(item: Note(tags:[Tags.loc]), newItem: true),
                  ),
                );
                if (result != null && context.mounted) {
                  _onShowPage(context, NoteListPage(selectedTags:[Tags.loc]));
                }
              },
            ),
            WidgetDualActionButton(
              label: 'Notes',
              icon: Icons.bookmark,
              onMainPressed: () =>
                  _onShowPage(context, NoteListPage()),
              onAddPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NoteItemPage(item: Note(), newItem: true),
                  ),
                );
                if (result != null && context.mounted) {
                  _onShowPage(context, NoteListPage());
                }
              },
            ),

            WidgetDualActionButton(
              label: 'Expenses',
              icon: Icons.euro,
              onMainPressed: () =>
                  _onShowPage(context, const TransactionMainPage()),
              onAddPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionItemPage(),
                  ),
                );
                if (result != null && context.mounted) {
                  _onShowPage(context, const TransactionMainPage());
                }
              },
            ),
            _buildScrollableSubfunctions(
              height: 60,
              subIcons: [
                {'icon': Icons.coffee_outlined, 'name': 'Cafe Essen'},
                {'icon': Icons.bakery_dining, 'name': 'Frühstück Essen'},
                {'icon': Icons.local_dining, 'name': 'Restaurant Essen'},
                {'icon': Icons.shopping_cart, 'name': 'Einkauf Essen'},
                {'icon': Icons.directions_bus, 'name': 'Bus Transport'},
                {'icon': Icons.local_taxi, 'name': 'Taxi Transport'},
                {'icon': Icons.attractions, 'name': 'Einritt'},
                {'icon': Icons.hotel, 'name': 'Hotel'},
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Horizontally scrollable subfunction icons (below main button)
  Widget _buildScrollableSubfunctions({
    required double height,
    required List<Map<String, dynamic>> subIcons,
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
            child: IconButton(
              icon: Icon(sub['icon'], size: 28),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TransactionItemPage(category: sub['name']),
                  ),
                );
                if (result != null && context.mounted) {
                  _onShowPage(context, const TransactionMainPage());
                }
              },
            ),
          );
        },
      ),
    );
  }
}
