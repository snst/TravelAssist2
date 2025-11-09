import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:travelassist2/widgets/widget_icon_button.dart';

import '../place_list/place.dart';
import '../place_list/place_item_page.dart';
import '../place_list/place_list_page.dart';
import '../todo_list/todo_item_page.dart';
import '../todo_list/todo_list_page.dart';
import '../utils/globals.dart';
import '../utils/json_export.dart';
import '../utils/travel_assist_utils.dart';
import '../widgets/widget_export.dart';
import 'calculator/calculator.dart';
import 'calculator/calculator_page.dart';
import 'currency/currency_list_page.dart';
import 'currency/currency_provider.dart';
import 'note_list/note.dart';
import 'note_list/note_item_page.dart';
import 'note_list/note_list_page.dart';
import 'note_list/note_provider.dart';
import 'place_list/place_provider.dart';
import 'providers/isar_service.dart';
import 'todo_list/todo_provider.dart';
import 'transaction_list/transaction_item_page.dart';
import 'transaction_list/transaction_main_page.dart';
import 'transaction_list/transaction_provider.dart';
import 'widgets/widget_dual_action_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isarService = IsarService();
  await isarService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Calculator()),
        ChangeNotifierProvider(create: (context) => TodoProvider(isarService.isar)),
        ChangeNotifierProvider(create: (context) => CurrencyProvider(isarService.isar)),
        ChangeNotifierProvider(create: (context) => TransactionProvider(isarService.isar)),
        ChangeNotifierProvider(create: (context) => NoteProvider(isarService.isar)),
        ChangeNotifierProvider(create: (context) => PlaceProvider(isarService.isar)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Txt.appTitle,
      //theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
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
    List<String> tags = link.startsWith("https://maps.app.goo.gl") ? [Tag.map] : [];
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NoteItemPage(
            item: Note(link: link, tags: tags),
            newItem: true,
            title: Txt.note,
            createReplacementPage: () => const NoteListPage(selectedTags: [Tag.note]),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Access the provider here using `context.read` as the context is available.
    // We use `read` because we don't need to rebuild the widget when the provider changes.
    // Listen to media sharing coming from outside the app while the app is in the memory.
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      setState(() {
        handleSharedFile(value[0]);
      });
    });

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
        title: const Text(Txt.appTitle),
        actions: [
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              const PopupMenuItem(value: 1, child: Text(Txt.currencyRates)),
              const PopupMenuItem(value: 5, child: Text(Txt.notesStorageDir)),
              const PopupMenuItem(value: 6, child: Text(Txt.journey)),
              const PopupMenuItem(value: 2, child: Text(Txt.checklist)),
              const PopupMenuItem(value: 3, child: Text(Txt.allNotes)),
              const PopupMenuItem(value: 4, child: Text(Txt.expenses)),
            ],
            elevation: 1,
            onSelected: (value) {
              switch (value) {
                case 1:
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CurrencyListPage()));
                  break;
                case 2:
                  showImportExportPage(context, Txt.checklist, Provider.of<TodoProvider>(context, listen: false));
                  break;
                case 3:
                  showImportExportPage(context, Txt.allNotes, Provider.of<NoteProvider>(context, listen: false));
                  break;
                case 4:
                  showImportExportPage(context, Txt.expenses, Provider.of<TransactionProvider>(context, listen: false));
                  break;
                case 5:
                  selectBookmarkFolder();
                  break;
                case 6:
                  showImportExportPage(context, Txt.journey, Provider.of<PlaceProvider>(context, listen: false));
                  break;
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: pagePadding,
        child: Column(
          children: [
            WidgetDualActionButton(
              label: Txt.calculator,
              icon: Icons.calculate,
              onMainPressed: () => _onShowPage(context, const CalculatorPage()),
            ),

            WidgetDualActionButton(
              label: Txt.journey,
              icon: Icons.timeline,
              onMainPressed: () => _onShowPage(context, const PlaceListPage()),
              onAddPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlaceItemPage(
                      item: Place(title: ''),
                      newItem: true,
                      createReplacementPage: () => const PlaceListPage(),
                    ),
                  ),
                );
              },
            ),

            WidgetDualActionButton(
              label: Txt.checklist,
              icon: Icons.checklist,
              onMainPressed: () => _onShowPage(context, const TodoListPage()),
              onAddPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TodoItemPage(createReplacementPage: () => const TodoListPage()),
                  ),
                );
              },
            ),

            WidgetDualActionButton(
              label: Txt.allNotes,
              icon: Icons.notes,
              onMainPressed: () => _onShowPage(context, NoteListPage(selectedTags: [])),
              onAddPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteItemPage(
                      item: Note(tags: []),
                      newItem: true,
                      title: Txt.note,
                      createReplacementPage: () => const NoteListPage(selectedTags: [Tag.note]),
                    ),
                  ),
                );
              },
            ),
            _buildScrollableNotes(
              tagIcons: const [
                TagIcon(tags: [Tag.star], icon: MyIcons.star),
                TagIcon(tags: [Tag.note], icon: MyIcons.note),
                TagIcon(tags: [Tag.hotel], icon: MyIcons.hotel),
                TagIcon(tags: [Tag.shop], icon: MyIcons.shop),
                TagIcon(tags: [Tag.restaurant], icon: MyIcons.restaurant),
                TagIcon(tags: [Tag.guide], icon: MyIcons.guide),
                TagIcon(tags: [Tag.gps], icon: MyIcons.gps),
                TagIcon(tags: [Tag.map], icon: MyIcons.map),
                TagIcon(tags: [Tag.bus], icon: MyIcons.bus),
                TagIcon(tags: [Tag.attraction], icon: MyIcons.attraction),
              ],
            ),

            WidgetDualActionButton(
              label: Txt.expenses,
              icon: Icons.euro,
              onMainPressed: () => _onShowPage(context, const TransactionMainPage()),
              onAddPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionItemPage(createReplacementPage: () => const TransactionMainPage()),
                  ),
                );
              },
            ),
            _buildScrollableExpense(
              tagIcons: const [
                TagIcon(tags: [Tag.cafe, Tag.food], icon: MyIcons.cafe),
                TagIcon(tags: [Tag.breakfast, Tag.food], icon: MyIcons.breakfast),
                TagIcon(tags: [Tag.restaurant, Tag.food], icon: MyIcons.restaurant),
                TagIcon(tags: [Tag.shop, Tag.food], icon: MyIcons.shop),
                TagIcon(tags: [Tag.bus, Tag.transport], icon: MyIcons.bus),
                TagIcon(tags: [Tag.taxi, Tag.transport], icon: MyIcons.taxi),
                TagIcon(tags: [Tag.attraction], icon: MyIcons.attraction),
                TagIcon(tags: [Tag.hotel], icon: MyIcons.hotel),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableExpense({required List<TagIcon> tagIcons}) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tagIcons.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = tagIcons[index];
          return WidgetIconButton(
            icon: item.icon,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TransactionItemPage(tags: item.tags, createReplacementPage: () => const TransactionMainPage()),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildScrollableNotes({required List<TagIcon> tagIcons}) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tagIcons.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = tagIcons[index];
          return WidgetIconButton(
            icon: item.icon,
            onPressed: () {
              _onShowPage(context, NoteListPage(selectedTags: item.tags));
            },
          );
        },
      ),
    );
  }
}

void showImportExportPage(BuildContext context, String title, JsonExport je) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: Text(title)),
          body: WidgetExport(fileName: title, toJson: je.toJson, fromJson: je.fromJson, clearJson: je.clear),
        );
      },
    ),
  );
}
