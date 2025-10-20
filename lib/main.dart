import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'bookmark_list/bookmark.dart';
import 'bookmark_list/bookmark_item_page.dart';
import 'bookmark_list/bookmark_list_page.dart';
import 'bookmark_list/bookmark_provider.dart';
import 'calculator/calculator.dart';
import 'calculator/calculator_page.dart';
import 'currency/currency_list_page.dart';
import 'currency/currency_provider.dart';
import 'location_list/location_item_page.dart';
import 'location_list/location_list_page.dart';
import 'location_list/location_provider.dart';
import 'memo_list/memo_item_page.dart';
import 'memo_list/memo_list_page.dart';
import 'memo_list/memo_provider.dart';
import 'todo_list/todo_item_page.dart';
import 'todo_list/todo_list_page.dart';
import 'todo_list/todo_provider.dart';
import 'transaction_list/transaction_item_page.dart';
import 'transaction_list/transaction_main_page.dart';
import 'transaction_list/transaction_provider.dart';
import 'widgets/widget_dual_action_button.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TodoProvider()),
        ChangeNotifierProvider(create: (context) => CurrencyProvider()),
        ChangeNotifierProvider(create: (context) => TransactionProvider()),
        ChangeNotifierProvider(create: (context) => LocationProvider()),
        ChangeNotifierProvider(create: (context) => Calculator()),
        ChangeNotifierProvider(create: (context) => MemoProvider()),
        ChangeNotifierProvider(create: (context) => BookmarkProvider()),
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
  late BookmarkProvider _bookmarkProvider;

  void handleSharedFile(SharedMediaFile file) async {
    final link = await moveSharedImageToDataFolder(file.path);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookmarkItemPage(item: Bookmark(link: link)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Access the provider here using `context.read` as the context is available.
    // We use `read` because we don't need to rebuild the widget when the provider changes.
    _bookmarkProvider = context.read<BookmarkProvider>();
    // Listen to media sharing coming from outside the app while the app is in the memory.
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      (value) {
        setState(() {
          handleSharedFile(value[0]);
        });
      },
      onError: (err) {
        print("getIntentDataStream error: $err");
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
            WidgetDualActionButton(
              label: 'Locations',
              icon: Icons.map,
              onMainPressed: () =>
                  _onShowPage(context, const LocationListPage()),
              onAddPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LocationItemPage()),
                );
                if (result != null && context.mounted) {
                  _onShowPage(context, const LocationListPage());
                }
              },
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
              label: 'Memos',
              icon: Icons.note,
              onMainPressed: () => _onShowPage(context, const MemoListPage()),
              onAddPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MemoItemPage()),
                );
                if (result != null && context.mounted) {
                  _onShowPage(context, const MemoListPage());
                }
              },
            ),

            WidgetDualActionButton(
              label: 'Bookmarks',
              icon: Icons.bookmark,
              onMainPressed: () =>
                  _onShowPage(context, const BookmarkListPage()),
              onAddPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BookmarkItemPage(item: Bookmark(link: "")),
                  ),
                );
                if (result != null && context.mounted) {
                  _onShowPage(context, const BookmarkListPage());
                }
              },
            ),

            WidgetDualActionButton(
              label: 'Expenses',
              icon: Icons.attach_money,
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
