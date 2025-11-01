import 'dart:io';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:travelassist2/note_list/note.dart';
import 'package:travelassist2/widgets/widget_multi_line_input.dart';

import '../utils/globals.dart';
import '../utils/map.dart';
import '../utils/travel_assist_utils.dart';
import '../widgets/widget_confirm_dialog.dart';
import '../widgets/widget_tags.dart';
import '../widgets/widget_text_input.dart';
import 'note_provider.dart';

Future<String> moveSharedImageToDataFolder(String srcPath) async {
  final file = File(srcPath);
  if (await file.exists()) {
    String? destDir = await getBookmarkFolder();
    if (destDir != null) {
      final fileName = path.basename(srcPath);
      String destPath = path.join(destDir, fileName);
      final newFile = await file.copy(destPath);
      srcPath = newFile.uri.path;
    }
  }
  return srcPath;
}

class NoteItemPage extends StatefulWidget {
  NoteItemPage({
    super.key,
    required this.item,
    this.newItem = false,
    this.title = Txt.note,
  }) : modifiedItem = item.clone();

  final Note item;
  final Note modifiedItem;
  final bool newItem;
  final String title;

  @override
  State<NoteItemPage> createState() => _NoteItemPageState();
}

class _NoteItemPageState extends State<NoteItemPage> {
  late StringTagController _stringTagController;
  late bool _doEdit;

  NoteProvider getProvider(BuildContext context) {
    return Provider.of<NoteProvider>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    _stringTagController = StringTagController();
    _doEdit = false;
    if (widget.newItem && widget.modifiedItem.tags.contains(Tag.gps)) {
      updatePosition(widget.modifiedItem);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _stringTagController.dispose();
  }

  void updatePosition(Note note) async {
    final String position = await getPositionString();
    if (mounted) {
      setState(() {
        note.link = "geo:$position";
      });
    }
  }

  bool save(BuildContext context) {
    var tags = _stringTagController.getTags;
    widget.modifiedItem.tags = tags ?? [];
    widget.item.update(widget.modifiedItem);
    getProvider(context).add(widget.item);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (!widget.newItem)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() {
                _doEdit = true;
              }),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: FutureBuilder<List<String>>(
          future: provider.getTags(),
          builder: (context, asyncSnapshot) {
            return Column(
              children: [
                WidgetTags(
                  allTags: asyncSnapshot.data ?? [],
                  tags: widget.modifiedItem.tags,
                  stringTagController: _stringTagController,
                ),
                SizedBox(height: 5),
                WidgetMultiLineInput(
                  hintText: Txt.comment,
                  initalText: widget.modifiedItem.comment,
                  onChanged: (value) => widget.modifiedItem.comment = value,
                  lines: 5,
                ),
                SizedBox(height: 5),
                WidgetTextInput(
                  text: widget.modifiedItem.link,
                  hintText: 'Enter Link',
                  onChanged: (value) => widget.modifiedItem.link = value,
                  //autofocus: widget.item == null, // new item
                ),

                SizedBox(height: 5),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(widget.modifiedItem.getDateTimeStr()),
                ),

                SizedBox(height: 5),

                if (_doEdit || widget.newItem)
                  Row(
                    children: [
                      const Spacer(),
                      ElevatedButton(
                        child: const Text('GPS'),
                        onPressed: () {
                          updatePosition(widget.modifiedItem);
                          //Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),

                      if (!widget.newItem)
                        ElevatedButton(
                          child: const Text('Delete'),
                          onPressed: () {
                            showConfirmationDialog(
                              context: context,
                              title: 'Confirm Delete',
                              text:
                                  'Are you sure you want to delete this item?',
                              onConfirm: () {
                                getProvider(context).delete(widget.item);
                                //getPackingList(context).delete(widget.item!);
                                Navigator.of(context).pop();
                                //Navigator.of(context).popUntil((route) => route.isFirst);
                              },
                            );
                          },
                        ),

                      ElevatedButton(
                        child: const Text('Save'),
                        onPressed: () {
                          if (save(context)) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: (!_doEdit && !widget.newItem)
          ? FloatingActionButton(
              onPressed: () async {
                openExternally(context, widget.modifiedItem.link);
              },
              child: const Icon(Icons.open_in_new),
            )
          : null,
    );
  }
}
