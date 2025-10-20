import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:provider/provider.dart';

import '../widgets/widget_combobox.dart';
import '../widgets/widget_confirm_dialog.dart';
import '../widgets/widget_text_input.dart';
import 'todo_item.dart';
import 'todo_provider.dart';
import '../widgets/widget_item_edit_actions.dart';

class TodoItemPage extends StatefulWidget {
  TodoItemPage({super.key, this.item})
    : modifiedItem = item == null ? TodoItem(quantity: 1) : item.clone();

  final TodoItem? item;
  final TodoItem modifiedItem;

  @override
  State<TodoItemPage> createState() => _PackedItemPageState();
}

class _PackedItemPageState extends State<TodoItemPage> {
  TodoProvider getPackingList(BuildContext context) {
    return Provider.of<TodoProvider>(context, listen: false);
  }

  void saveAndClose(BuildContext context) {
    if (save(context)) {
      Navigator.of(context).pop(true);
    }
  }

  bool save(BuildContext context) {
    if (widget.modifiedItem.name.isNotEmpty) {
      if (widget.item != null) {
        widget.item!.update(widget.modifiedItem);
        getPackingList(context).add(widget.item!);
      } else {
        // new item
        getPackingList(context).add(widget.modifiedItem);
      }
      //Navigator.of(context).pop(true);
      return true;
    } else {
      return false;
    }
  }


  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    controller.text = widget.modifiedItem.category;
    List<String> categories = getPackingList(context).getCategories();

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("To-Do")),
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
            WidgetComboBox(
              controller: TextEditingController(),
              selectedText: widget.modifiedItem.category,
              hintText: 'Enter Category',
              filter: true,
              onChanged: (suggestion) {
                setState(() {
                  widget.modifiedItem.category = suggestion;
                });
              },
              items: categories,
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                  child: SpinBox(
                    value: widget.modifiedItem.quantity.toDouble(),
                    decoration: const InputDecoration(
                      constraints: BoxConstraints.tightFor(width: 150),
                      labelText: 'Quantity',
                    ),
                    onChanged: (value) =>
                        widget.modifiedItem.quantity = value.toInt(),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                  child: SpinBox(
                    value: widget.modifiedItem.used.toDouble(),
                    decoration: const InputDecoration(
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
              padding: const EdgeInsets.fromLTRB(0, 18, 0, 12),
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
                    saveAndClose(context);
                  }
                },
              ),
            ),
            WidgetItemEditActions(
              onSave: () { return save(context); },
              onDelete: (widget.item == null) ? null : () {
                getPackingList(context).delete(widget.item!);
              }
            ),

            TextField(
              controller: TextEditingController()
                ..text = widget.modifiedItem.comment,
              decoration: const InputDecoration(hintText: 'Comment'),
              onChanged: (value) => widget.modifiedItem.comment = value,
              keyboardType: TextInputType.multiline,
              minLines: 10,
              //Normal textInputField will be displayed
              maxLines: 10, // when user presses enter it will adapt to it
            ),
          ],
        ),
      ),
    );
  }
}
