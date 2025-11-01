import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:provider/provider.dart';

import '../widgets/widget_combobox.dart';
import '../widgets/widget_text_input.dart';
import 'todo_item.dart';
import 'todo_provider.dart';
import '../widgets/widget_item_edit_actions.dart';
import '../widgets/widget_comment.dart';

class TodoItemPage extends StatefulWidget {
  TodoItemPage({super.key, this.item})
    : modifiedItem = item == null ? TodoItem(quantity: 1) : item.clone();

  final TodoItem? item;
  final TodoItem modifiedItem;

  @override
  State<TodoItemPage> createState() => _PackedItemPageState();
}

class _PackedItemPageState extends State<TodoItemPage> {

  void saveAndClose(BuildContext context, TodoProvider provider) {
    if (save(provider)) {
      Navigator.of(context).pop(true);
    }
  }

  bool save(TodoProvider provider) {
    if (widget.modifiedItem.name.isNotEmpty) {
      if (widget.item != null) {
        widget.item!.update(widget.modifiedItem);
        provider.add(widget.item!);
      } else {
        // new item
        provider.add(widget.modifiedItem);
      }
      return true;
    } else {
      return false;
    }
  }


  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    controller.text = widget.modifiedItem.category;
    final provider = context.watch<TodoProvider>();

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Check Item")),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            WidgetTextInput(
              text: widget.modifiedItem.name,
              hintText: 'Enter Name',
              onChanged: (value) => widget.modifiedItem.name = value,
              autofocus: widget.item == null, // new item
            ),
            SizedBox(height: 5),
            FutureBuilder(
              future: provider.getCategories(),
              builder: (context, asyncSnapshot) {
                return WidgetComboBox(
                  controller: TextEditingController(),
                  selectedText: widget.modifiedItem.category,
                  hintText: 'Enter Category',
                  filter: true,
                  onChanged: (suggestion) {
                    setState(() {
                      widget.modifiedItem.category = suggestion;
                    });
                  },
                  items: asyncSnapshot.data ?? [],
                );
              }
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                  child: SpinBox(
                    value: widget.modifiedItem.quantity.toDouble(),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      constraints: BoxConstraints.tightFor(width: 150),
                      labelText: 'Quantity',
                    ),
                    onChanged: (value) =>
                        widget.modifiedItem.quantity = value.toInt(),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                  child: SpinBox(
                    value: widget.modifiedItem.used.toDouble(),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      constraints: BoxConstraints.tightFor(width: 150),
                      labelText: 'Used',
                    ),
                    onChanged: (value) =>
                        widget.modifiedItem.used = value.toInt(),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 9, 0, 0),
              child: SegmentedButton<TodoItemStateEnum>(
                showSelectedIcon: false,
                segments: const <ButtonSegment<TodoItemStateEnum>>[
                  ButtonSegment<TodoItemStateEnum>(
                    value: TodoItemStateEnum.skipped,
                    label: Text('skipped'),
                    //  icon: Icon(Icons.calendar_view_week)
                  ),
                  ButtonSegment<TodoItemStateEnum>(
                    value: TodoItemStateEnum.open,
                    label: Text('open'),
                    // icon: Icon(Icons.calendar_view_day)
                  ),
                  ButtonSegment<TodoItemStateEnum>(
                    value: TodoItemStateEnum.done,
                    label: Text('done'),
                    //  icon: Icon(Icons.calendar_view_month)
                  ),
                ],
                selected: <TodoItemStateEnum>{widget.modifiedItem.state},
                onSelectionChanged: (Set<TodoItemStateEnum> newSelection) {
                  setState(() {
                    widget.modifiedItem.state = newSelection.first;
                  });
                  if (widget.item != null) {
                    saveAndClose(context, provider);
                  }
                },
              ),
            ),
            WidgetComment(comment: widget.modifiedItem.comment, onChanged: (value) => widget.modifiedItem.comment = value),
            WidgetItemEditActions(
              onSave: () { return save(provider); },
              onDelete: (widget.item == null) ? null : () {
                provider.delete(widget.item!);
              }
            ),

          ],
        ),
      ),
    );
  }
}
