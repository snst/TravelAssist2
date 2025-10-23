import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:travelassist2/bookmark_list/bookmark.dart';

import '../utils/travel_assist_utils.dart';
import '../widgets/widget_comment.dart';
import '../widgets/widget_item_edit_actions.dart';
import '../widgets/widget_tags.dart';
import '../widgets/widget_text_input.dart';
import 'bookmark_provider.dart';

Future<Directory> getAppDataDirectory() async {
  return await getApplicationDocumentsDirectory();
}

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

class BookmarkItemPage extends StatefulWidget {
  BookmarkItemPage({super.key, required this.item, this.newItem = false})
    : modifiedItem = item.clone(),
      comment = StringHolder(item.comment);

  final Bookmark item;
  final Bookmark modifiedItem;
  final bool newItem;
  final StringHolder comment;

  @override
  State<BookmarkItemPage> createState() => _PackedItemPageState();
}

class _PackedItemPageState extends State<BookmarkItemPage> {
  late StringTagController _stringTagController;
  List<String> _initialTags = [];

  BookmarkProvider getProvider(BuildContext context) {
    return Provider.of<BookmarkProvider>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    _stringTagController = StringTagController();
  }

  @override
  void dispose() {
    super.dispose();
    _stringTagController.dispose();
  }

  bool save(BuildContext context) {
    var tags = _stringTagController.getTags;
    widget.modifiedItem.tags = tags ?? [];
    widget.modifiedItem.comment = widget.comment.value;
    widget.item.update(widget.modifiedItem);
    getProvider(context).add(widget.item);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_initialTags.isEmpty) {
      _initialTags = getProvider(context).getTags();
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmark')),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            WidgetTags(
              allTags: _initialTags,
              tags: widget.modifiedItem.tags,
              stringTagController: _stringTagController,
            ),
            SizedBox(height: 5),
            WidgetTextInput(
              text: widget.modifiedItem.link,
              hintText: 'Enter Link',
              onChanged: (value) => widget.modifiedItem.link = value,
              //autofocus: widget.item == null, // new item
            ),
            SizedBox(height: 5),
            WidgetComment(comment: widget.comment),

            SizedBox(height: 5),


            ElevatedButton(
              child: const Text('Open'),
              onPressed: () async {
                openExternally(widget.modifiedItem.link);
              },
            ),

            WidgetItemEditActions(
              onSave: () {
                return save(context);
              },
              onDelete: (widget.newItem)
                  ? null
                  : () {
                      getProvider(context).delete(widget.item);
                    },
            ),
          ],
        ),
      ),
    );
  }
}
