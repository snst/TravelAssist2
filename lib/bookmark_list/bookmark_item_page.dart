import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../widgets/widget_text_input.dart';
import 'bookmark_provider.dart';

class BookmarkItemPage extends StatefulWidget {
  BookmarkItemPage({super.key, required this.link});

  //: modifiedItem = item == null ? Bookmark(title: "", content: "") : item.clone();

  //final Memo? item;
  //final Memo modifiedItem;
  final String link;

  @override
  State<BookmarkItemPage> createState() => _PackedItemPageState();
}


class _PackedItemPageState extends State<BookmarkItemPage> {
  late StringTagController _stringTagController;
  late double _distanceToField;

  BookmarkProvider getPackingList(BuildContext context) {
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

  void saveAndClose(BuildContext context) {
    /*if (widget.modifiedItem.title.isNotEmpty) {
      if (widget.item != null) {
        widget.item!.update(widget.modifiedItem);
        getPackingList(context).add(widget.item!);
      } else {
        // new item
        getPackingList(context).add(widget.modifiedItem);
      }
      Navigator.of(context).pop(true);
    }*/
  }

  static const List<String> _initialTags = <String>[
    'c',
    'c++',
    'java',
    'json',
    'python',
    'javascript',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 74, 137, 92),
        centerTitle: true,
        title: const Text(
          'String Tag Autocomplete Demo...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            Autocomplete<String>(
              optionsViewBuilder: (context, onSelected, options) {
                return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 4.0),
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
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 74, 137, 92),
                                  ),
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
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onFieldSubmitted) {
                return TextFieldTags<String>(
                  textEditingController: textEditingController,
                  focusNode: focusNode,
                  textfieldTagsController: _stringTagController,
                  initialTags: const [
                    'yaml',
                    'gradle',
                  ],
                  textSeparators: const [' ', ','],
                  letterCase: LetterCase.normal,
                  validator: (String tag) {
                    if (tag == 'php') {
                      return 'No, please just no';
                    } else if (_stringTagController.getTags!.contains(tag)) {
                      return 'You\'ve already entered that';
                    }
                    return null;
                  },
                  inputFieldBuilder: (context, inputFieldValues) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                        controller: inputFieldValues.textEditingController,
                        focusNode: inputFieldValues.focusNode,
                        decoration: InputDecoration(
                          isDense: true,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 74, 137, 92),
                              width: 3.0,
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 74, 137, 92),
                              width: 3.0,
                            ),
                          ),
                          helperText: 'Enter language...',
                          helperStyle: const TextStyle(
                            color: Color.fromARGB(255, 74, 137, 92),
                          ),
                          hintText: inputFieldValues.tags.isNotEmpty
                              ? ''
                              : "Enter tag...",
                          errorText: inputFieldValues.error,
                          prefixIconConstraints:
                          BoxConstraints(maxWidth: _distanceToField * 0.74),
                          prefixIcon: inputFieldValues.tags.isNotEmpty
                              ? SingleChildScrollView(
                            controller:
                            inputFieldValues.tagScrollController,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                                children: inputFieldValues.tags
                                    .map((String tag) {
                                  return Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20.0),
                                      ),
                                      color: Color.fromARGB(255, 74, 137, 92),
                                    ),
                                    margin:
                                    const EdgeInsets.only(right: 10.0),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 4.0),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          child: Text(
                                            '#$tag',
                                            style: const TextStyle(
                                                color: Colors.white),
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
                                            color: Color.fromARGB(
                                                255, 233, 233, 233),
                                          ),
                                          onTap: () {
                                            inputFieldValues
                                                .onTagRemoved(tag);
                                          },
                                        )
                                      ],
                                    ),
                                  );
                                }).toList()),
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
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  const Color.fromARGB(255, 74, 137, 92),
                ),
              ),
              onPressed: () {
                _stringTagController.clearTags();
              },
              child: const Text(
                'CLEAR TAGS',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build2(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Bookmark"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            WidgetTextInput(
              text: widget.link,
              hintText: 'Enter Link',
              onChanged: (value) {},
              //onChanged: (value) => widget.modifiedItem.title = value,
              //autofocus: widget.item == null, // new item
            ),
            TextFieldTags<String>(
              textfieldTagsController: _stringTagController,
              initialTags: ['python', 'java'],
              textSeparators: const [' ', ','],
              validator: (String tag) {
                if (tag == 'php') {
                  return 'Php not allowed';
                }
                return null;
              },
              inputFieldBuilder: (context, inputFieldValues) {
                return TextField(
                  controller: inputFieldValues.textEditingController,
                  focusNode: inputFieldValues.focusNode,
                );
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
              ],
            ),

            /*
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

            */
          ],
        ),
      ),
    );
  }
}
