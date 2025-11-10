import 'package:flutter/material.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:provider/provider.dart';
import 'package:travelassist2/widgets/widget_icon_button.dart';

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
  late List<String> _selectedTags;

  @override
  void initState() {
    super.initState();
    _selectedTags = widget.selectedTags;
  }

  NoteProvider getProvider(BuildContext context) {
    return Provider.of<NoteProvider>(context, listen: false);
  }

  void selectTags(List<String> selectedItems) {
    setState(() {
      _selectedTags = selectedItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteProvider>();
    return FutureBuilder<NotesResult>(
      future: provider.filterNotesWithTag(_selectedTags),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final result = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(_selectedTags.isEmpty ? "All" : _selectedTags.join(' ')),
          ),
          body: Column(
            children: [
              Expanded(
                child: result.notes.isEmpty
                    ? const Center(child: Text('No items found.'))
                    : _buildNoteList(result.notes),
              ),

              WidgetTagFooter(tags: snapshot.data!.tags, selectedTags: _selectedTags, onSelectTags: selectTags),
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
                      item: Note(tags: _selectedTags),
                      newItem: true,
                      title: Txt.note,
                    ),
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoteList(List<Note> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        // Show newest items first
        final reverseIndex = items.length - 1 - index;
        return Card(
          child: ListTile(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NoteItemPage(item: items[reverseIndex])));
            },
            // on tap
            title: WidgetBookmark(bookmark: items[reverseIndex]),
            trailing: IconButton(
              icon: Icon(items[reverseIndex].getIcon()), // The icon on the right
              onPressed: () {
                openExternally(context, items[reverseIndex]);
              },
            ),
          ),
        );
      },
    );
  }
}

class WidgetTagFooter extends StatelessWidget {
  final List<String> tags;
  final List<String> selectedTags;
  final Function(List<String>) onSelectTags;

  const WidgetTagFooter({super.key, required this.tags, required this.selectedTags, required this.onSelectTags});

  @override
  Widget build(BuildContext context) {
    var tagCards = tags
        .map((tag) => MultiSelectCard(value: tag, label: tag, selected: selectedTags.contains(tag)))
        .toList();

    return SizedBox(
      height: 60,
      child: Row(
        children: [
          Expanded(
            child: MultiSelectContainer(
              // By providing a key that changes when selectedTags changes, we force Flutter
              // to recreate this widget and its state, reflecting the new selections.
              key: ValueKey(tagCards),
              showInListView: true,
              listViewSettings: ListViewSettings(
                scrollDirection: Axis.horizontal,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
              ),
              items: tagCards,
              onChange: (allSelectedItems, selectedItem) {
                onSelectTags(allSelectedItems.cast<String>());
              },
            ),
          ),
          WidgetIconButton(
            icon: MyIcons.clear,
            scale: 0.8,
            onPressed: () {
              onSelectTags([]);
            },
          ),
        ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bookmark.comment.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(bookmark.comment, style: const TextStyle(fontSize: 16), maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
          if (bookmark.link.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              bookmark.shortLink(),
              style: TextStyle(
                fontSize: 15,
                //color: Theme.of(context).colorScheme.outline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (bookmark.tags.isNotEmpty) ...[
            Text(
              bookmark.tags.map((tag) => '#$tag').join(' '),
              style: TextStyle(
                fontSize: 15, //color: Theme.of(context).colorScheme.surfaceTint,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
