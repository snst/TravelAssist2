import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:travelassist2/bookmark_list/bookmark.dart';

import '../utils/travel_assist_utils.dart';
import '../widgets/widget_item_edit_actions.dart';
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
    : modifiedItem = item.clone();

  final Bookmark item;
  final Bookmark modifiedItem;
  final bool newItem;

  @override
  State<BookmarkItemPage> createState() => _PackedItemPageState();
}

class _PackedItemPageState extends State<BookmarkItemPage> {
  late StringTagController _stringTagController;
  late double _distanceToField;

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
    widget.item.update(widget.modifiedItem);
    getProvider(context).add(widget.item);
    return true;
  }

  List<String> _initialTags = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
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

            Autocomplete<String>(
              optionsViewBuilder: (context, onSelected, options) {
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 4.0,
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Material(
                      elevation: 4.0,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                            return TextButton(
                              onPressed: () {
                                onSelected(option);
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '#$option',
                                  textAlign: TextAlign.left,
                                  /*style: const TextStyle(
                                    color: Color.fromARGB(255, 74, 137, 92),
                                  ),*/
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return _initialTags.where((String option) {
                  return option.contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selectedTag) {
                _stringTagController.onTagSubmitted(selectedTag);
              },
              fieldViewBuilder:
                  (
                    context,
                    textEditingController,
                  focusNode,
                    onFieldSubmitted,
                  ) {
                    return TextFieldTags<String>(
                      textEditingController: textEditingController,
                      focusNode: focusNode,
                      textfieldTagsController: _stringTagController,
                      initialTags: widget.modifiedItem.tags,
                      textSeparators: const [' ', ','],
                      validator: (String tag) {
                        if ((_stringTagController.getTags ?? []).contains(
                          tag,
                        )) {
                          return 'You\'ve already entered that';
                        }
                        return null;
                      },
                      inputFieldBuilder: (context, inputFieldValues) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: TextField(
                            autofocus: true,
                            controller: inputFieldValues.textEditingController,
                            focusNode: inputFieldValues.focusNode,
                            decoration: InputDecoration(
                              isDense: true,
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  //color: Color.fromARGB(255, 74, 137, 92),
                                  width: 3.0,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  //color: Color.fromARGB(255, 74, 137, 92),
                                  width: 3.0,
                                ),
                              ),
                              /* helperText: 'Enter tags...',
                              helperStyle: const TextStyle(
                                //color: Color.fromARGB(255, 74, 137, 92),
                              ),*/
                              hintText: inputFieldValues.tags.isNotEmpty
                                  ? ''
                                  : "Enter tag...",
                              errorText: inputFieldValues.error,
                              prefixIconConstraints: BoxConstraints(
                                maxWidth: _distanceToField * 0.74,
                              ),
                              prefixIcon: inputFieldValues.tags.isNotEmpty
                                  ? SingleChildScrollView(
                                      controller:
                                          inputFieldValues.tagScrollController,
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: inputFieldValues.tags.map((
                                          String tag,
                                        ) {
                                          return Container(
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(20.0),
                                              ),
                                              color: Color.fromARGB(
                                                255,
                                                74,
                                                137,
                                                92,
                                              ),
                                            ),
                                            margin: const EdgeInsets.only(
                                              right: 10.0,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0,
                                              vertical: 4.0,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                InkWell(
                                                  child: Text(
                                                    '#$tag',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    //print("$tag selected");
                                                  },
                                                ),
                                                const SizedBox(width: 4.0),
                                                InkWell(
                                                  child: const Icon(
                                                    Icons.cancel,
                                                    size: 14.0,
                                                    /*color: Color.fromARGB(
                                                      255,
                                                      233,
                                                      233,
                                                      233,
                                                    ),*/
                                                  ),
                                                  onTap: () {
                                                    inputFieldValues
                                                        .onTagRemoved(tag);
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    )
                                  : null,
                            ),
                            onChanged: inputFieldValues.onTagChanged,
                            onSubmitted: inputFieldValues.onTagSubmitted,
                          ),
                        );
                      },
                    );
                  },
            ),
            SizedBox(height: 5),

            WidgetTextInput(
              text: widget.modifiedItem.link,
              hintText: 'Enter Link',
              onChanged: (value) => widget.modifiedItem.link = value,
              //autofocus: widget.item == null, // new item
            ),
            SizedBox(height: 5),
            WidgetTextInput(
              text: widget.modifiedItem.title,
              hintText: 'Enter Title',
              onChanged: (value) => widget.modifiedItem.title = value,
              //autofocus: widget.item == null, // new item
            ),
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
