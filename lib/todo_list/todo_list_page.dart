import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';

import '../utils/globals.dart';
import '../widgets/widget_export.dart';
import 'todo_item.dart';
import 'todo_item_page.dart';
import 'todo_list_widget.dart';
import 'todo_provider.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  static int pageIndex = 2;

  @override
  State<TodoListPage> createState() => _PackingListPageState();
}

class _PackingListPageState extends State<TodoListPage> {
  bool _listEditable = false;
  int _selectedFilterIndex = 1;
  int _selectedBottomIndex = 1;

  TodoItemStateEnum bottomIndexToStateEnum(int index) {
    final filters = [
      TodoItemStateEnum.skipped,
      TodoItemStateEnum.open,
      TodoItemStateEnum.done,
    ];
    return filters[index];
  }

  void toggleEdit() {
    _listEditable = !_listEditable;
    setState(() {});
  }

  Future<void> _showEditDialog(TodoItem? item) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TodoItemPage(item: item)),
    );
  }


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(Txt.checklist),
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist),
            onPressed: () => toggleEdit()
          ),
        ],
      ),
      body: FutureBuilder(
        future: provider.getFilteredItems(
          bottomIndexToStateEnum(_selectedFilterIndex),
        ),
        builder: (context, asyncSnapshot) {
          return GroupedListView<TodoItem, String>(
            elements: asyncSnapshot.data ?? [],
            groupBy: (TodoItem element) => element.category,
            groupComparator: (value1, value2) => value2.compareTo(value1),
            itemComparator: (TodoItem element1, TodoItem element2) =>
                element1.name.compareTo(element2.name),
            order: GroupedListOrder.DESC,
            useStickyGroupSeparators: false,
            groupSeparatorBuilder: (String value) => Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
              child: Align(
                alignment: Alignment.center,
                child: Text(value, textAlign: TextAlign.center),
              ),
            ),
            itemBuilder: (context, item) => TodoListWidget(
              item: item,
              onItemChanged: (item) {
                provider.add(item, notify: true);
              },
              onEditItem: (item) => _showEditDialog(item),
              editable: _listEditable,
              filterIndex: bottomIndexToStateEnum(_selectedFilterIndex),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.ban),
            label: 'Skipped',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.square),
            label: 'Open',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.squareCheck),
            label: 'Done',
          ),
        ],
        currentIndex: _selectedBottomIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedBottomIndex = index;
            if (index <= 2) {
              _selectedFilterIndex = index;
            }
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(null),
        tooltip: 'Add item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
