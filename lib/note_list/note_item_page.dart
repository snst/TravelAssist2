import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:travelassist2/note_list/note.dart';

import '../utils/globals.dart';
import '../utils/travel_assist_utils.dart';
import '../widgets/widget_comment.dart';
import '../widgets/widget_confirm_dialog.dart';
import '../widgets/widget_formatted_text.dart';
import '../widgets/widget_tags.dart';
import '../widgets/widget_text_input.dart';
import 'note_provider.dart';
import '../utils/map.dart';


Future<String> moveSharedImageToDataFolder(String srcPath) async {
  final file = File(srcPath);
  if (await file.exists()) {
    String? destDir = await getBookmarkFolder();
    if (destDir != null) {
      final fileName = p.basename(srcPath);
      String destPath = path.join(destDir, fileName);
      final newFile = await file.copy(destPath);
      srcPath = newFile.uri.path;
    }
  }
  return srcPath;
}

class NoteItemPage extends StatefulWidget {
  NoteItemPage({super.key, required this.item, this.newItem = false, this.title="Bookmark"})
    : modifiedItem = item.clone();

  final Note item;
  final Note modifiedItem;
  final bool newItem;
  final String title;
  bool doEdit = false;

  @override
  State<NoteItemPage> createState() => _PackedItemPageState();
}

class _PackedItemPageState extends State<NoteItemPage> {
  late StringTagController _stringTagController;

  NoteProvider getProvider(BuildContext context) {
    return Provider.of<NoteProvider>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    _stringTagController = StringTagController();
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
        actions: [
          if (!widget.newItem)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() {widget.doEdit = true;} )  ,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                WidgetComment(
                  comment: widget.modifiedItem.comment,
                  onChanged: (value) => widget.modifiedItem.comment = value,
                ),
                SizedBox(height: 5),
                WidgetTextInput(
                  text: widget.modifiedItem.link,
                  hintText: 'Enter Link',
                  onChanged: (value) => widget.modifiedItem.link = value,
                  //autofocus: widget.item == null, // new item
                ),

                SizedBox(height: 5),
                FormattedText(
                  title: "Date",
                  content: widget.modifiedItem.getDateTimeStr(),
                ),

                SizedBox(height: 5),

                if (widget.doEdit || widget.newItem)
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
                              text: 'Are you sure you want to delete this item?',
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
                  )
              ],
            );
          }
        ),
      ),
      floatingActionButton: (!widget.doEdit && !widget.newItem)
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
