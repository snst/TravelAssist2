import 'package:flutter/material.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:provider/provider.dart';

import '../utils/globals.dart';
import '../utils/travel_assist_utils.dart';
import 'note.dart';
import 'note_item_page.dart';
import 'note_provider.dart';

class NoteListPage extends StatefulWidget {
  final List<String> selectedTags;

  const NoteListPage({super.key, this.selectedTags = const []});

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  late List<String> selectedTags;

  @override
  void initState() {
    super.initState();
    selectedTags = widget.selectedTags;
  }

  void selectTags(List<String> selectedItems) {
    setState(() {
      selectedTags = selectedItems.cast<String>();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteProvider>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(selectedTags.isEmpty ? "All" : selectedTags.join(' ')),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Note>>(
              future: provider.getWithTag(selectedTags),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const Center(child: Text('No items found.'));
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final reverseIndex = items.length - 1 - index;
                    return Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NoteItemPage(item: items[reverseIndex]),
                            ),
                          );
                        },
                        title: WidgetBookmark(bookmark: items[reverseIndex]),
                        trailing: IconButton(
                          icon: items[reverseIndex].getIcon(),
                          // The icon on the right
                          onPressed: () {
                            openExternally(context, items[reverseIndex].link);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(
            height: 60,
            width: double.infinity,
            // Take the full width of the parent (within padding)
            child: FutureBuilder<List<String>>(
              future: provider.getTags(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final tags = snapshot.data ?? [];
                if (tags.isEmpty) {
                  return const SizedBox.shrink();
                }
                final tagCards = tags
                    .map(
                      (tag) => MultiSelectCard(
                        value: tag,
                        label: tag,
                        selected: selectedTags.contains(tag),
                      ),
                    )
                    .toList();
                return MultiSelectContainer(
                  showInListView: true,
                  listViewSettings: ListViewSettings(
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                  ),
                  items: tagCards,
                  onChange: (allSelectedItems, selectedItem) {
                    selectTags(allSelectedItems.cast<String>());
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 56.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoteItemPage(
                  item: Note(tags: selectedTags),
                  newItem: true,
                  title: Txt.note, //selectedTags.join(' '),
                ),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class WidgetBookmark extends StatelessWidget {
  final Note bookmark;

  const WidgetBookmark({super.key, required this.bookmark});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bookmark.tags.isNotEmpty) ...[
              Text(
                bookmark.tags.map((tag) => '#$tag').join(' '),
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.surfaceTint,
                ),
              ),
            ],
            if (bookmark.comment.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                bookmark.comment,
                style: const TextStyle(fontSize: 16),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (bookmark.link.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                bookmark.shortLink(),
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.secondaryFixed,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
