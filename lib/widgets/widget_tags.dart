import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';

class WidgetTags extends StatelessWidget {
  const WidgetTags({
    super.key,
    required this.allTags,
    required this.tags,
    required this.stringTagController,
  });

  final List<String> allTags;
  final List<String> tags;
  final StringTagController stringTagController;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsViewBuilder: (context, onSelected, options) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
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
                        child: Text('#$option', textAlign: TextAlign.left),
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
        return allTags.where((String option) {
          return option.contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selectedTag) {
        stringTagController.onTagSubmitted(selectedTag);
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextFieldTags<String>(
              textEditingController: textEditingController,
              focusNode: focusNode,
              textfieldTagsController: stringTagController,
              initialTags: tags,
              textSeparators: const [' ', ','],
              validator: (String tag) {
                if ((stringTagController.getTags ?? []).contains(tag)) {
                  return 'Already present';
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
                        borderSide: BorderSide(width: 3.0),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(width: 3.0),
                      ),
                      hintText: inputFieldValues.tags.isNotEmpty
                          ? ''
                          : "Enter tag...",
                      errorText: inputFieldValues.error,
                      prefixIconConstraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.74,
                      ),
                      prefixIcon: inputFieldValues.tags.isNotEmpty
                          ? SingleChildScrollView(
                              controller: inputFieldValues.tagScrollController,
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
                                      color: Color.fromARGB(255, 74, 137, 92),
                                    ),
                                    margin: const EdgeInsets.only(right: 10.0),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                      vertical: 4.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                          ),
                                          onTap: () {
                                            inputFieldValues.onTagRemoved(tag);
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
    );
  }
}
