import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../widgets/widget_item_edit_actions.dart';
import '../widgets/widget_text_input.dart';
import 'memo.dart';
import 'memo_provider.dart';

class MemoItemPage extends StatefulWidget {
  MemoItemPage({super.key, this.item})
    : modifiedItem = item == null ? Memo(title: "", content: "") : item.clone();

  final Memo? item;
  final Memo modifiedItem;

  @override
  State<MemoItemPage> createState() => _PackedItemPageState();
}

class _PackedItemPageState extends State<MemoItemPage> {
  MemoProvider getPackingList(BuildContext context) {
    return Provider.of<MemoProvider>(context, listen: false);
  }

  bool save(BuildContext context) {
    if (widget.modifiedItem.title.isNotEmpty) {
      if (widget.item != null) {
        widget.item!.update(widget.modifiedItem);
        getPackingList(context).add(widget.item!);
      } else {
        // new item
        getPackingList(context).add(widget.modifiedItem);
      }
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Memo")),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            WidgetTextInput(
              text: widget.modifiedItem.title,
              hintText: 'Enter Title',
              onChanged: (value) => widget.modifiedItem.title = value,
              autofocus: widget.item == null, // new item
            ),
            SizedBox(height: 5),
            TextField(
              controller: TextEditingController()
                ..text = widget.modifiedItem.content,
              decoration: const InputDecoration(hintText: 'Enter Content'),
              onChanged: (value) => widget.modifiedItem.content = value,
              keyboardType: TextInputType.multiline,
              minLines: 5,
              maxLines: 5, // when user presses enter it will adapt to it
            ),
            SizedBox(height: 5),
            ElevatedButton(
              child: const Text('Copy'),
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(text: widget.modifiedItem.content),
                );
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Copied to Clipboard')));
              },
            ),
            WidgetItemEditActions(
              onSave: () {
                return save(context);
              },
              onDelete: (widget.item == null)
                  ? null
                  : () {
                getPackingList(context).delete(widget.item!);
              },
            ),
          ],
        ),
      ),
    );
  }
}
