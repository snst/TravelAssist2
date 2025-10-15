import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../widgets/widget_confirm_dialog.dart';
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

  void saveAndClose(BuildContext context) {
    if (widget.modifiedItem.title.isNotEmpty) {
      if (widget.item != null) {
        widget.item!.update(widget.modifiedItem);
        getPackingList(context).add(widget.item!);
      } else {
        // new item
        getPackingList(context).add(widget.modifiedItem);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

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
              hintText: 'Title',
              onChanged: (value) => widget.modifiedItem.title = value,
              autofocus: widget.item == null, // new item
            ),
            SizedBox(height: 5),
            TextField(
              controller: TextEditingController()
                ..text = widget.modifiedItem.content,
              decoration: const InputDecoration(hintText: 'Content'),
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
            Row(
              children: [
                ElevatedButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),

                if (widget.item != null)
                  ElevatedButton(
                    child: const Text('Delete'),
                    onPressed: () {
                      showConfirmationDialog(
                        context: context,
                        title: 'Confirm Delete',
                        text: 'Are you sure you want to delete this item?',
                        onConfirm: () {
                          getPackingList(context).delete(widget.item!);
                          Navigator.of(context).pop();
                          //Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                      );
                    },
                  ),
                ElevatedButton(
                  child: const Text('Save'),
                  onPressed: () {
                    saveAndClose(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
