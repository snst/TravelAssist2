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
import '../widgets/widget_icon_button.dart';
import '../widgets/widget_item_edit_actions.dart';
import '../widgets/widget_layout.dart';
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
    this.createReplacementPage,
  }) : modifiedItem = item.clone();

  final Note item;
  final Note modifiedItem;
  final bool newItem;
  final String title;
  final Function? createReplacementPage;

  @override
  State<NoteItemPage> createState() => _NoteItemPageState();
}

class _NoteItemPageState extends State<NoteItemPage> {
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: pagePadding,
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
                VSpace(),
                WidgetMultiLineInput(
                  hintText: Txt.hintComment,
                  initalText: widget.modifiedItem.comment,
                  onChanged: (value) => widget.modifiedItem.comment = value,
                  lines: 5,
                ),
                VSpace(),

                Row(
                  children: [
                    Expanded(
                      child: WidgetTextInput(
                        text: widget.modifiedItem.link,
                        hintText: Txt.hintLink,
                        onChanged: (value) => widget.modifiedItem.link = value,
                      ),
                    ),
                    WidgetIconButton(
                      icon: widget.modifiedItem.getIcon(),
                      onPressed: () {
                        openExternally(context, widget.modifiedItem.link);
                      },
                    ),
                  ],
                ),

                VSpace(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(widget.modifiedItem.getDateTimeStr()),
                ),
                WidgetItemEditActions(
                  createReplacementPage: widget.createReplacementPage,
                  onSave: () {
                    return save(context);
                  },
                  onDelete: (widget.newItem)
                      ? null
                      : () {
                          getProvider(context).delete(widget.item);
                        },
                  leftWidget: [
                    WidgetIconButton(
                      icon: MyIcons.copy,
                      onPressed: () {
                        copyToClipboard(context, widget.modifiedItem.link);
                      },
                    ),
                    HSpace(),
                    WidgetIconButton(
                      icon: MyIcons.gps,
                      onPressed: () {
                        updatePosition(widget.modifiedItem);
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
