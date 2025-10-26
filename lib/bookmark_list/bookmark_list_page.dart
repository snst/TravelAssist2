import 'package:flutter/material.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:provider/provider.dart';

import '../utils/travel_assist_utils.dart';
import 'bookmark.dart';
import 'bookmark_item_page.dart';
import 'bookmark_provider.dart';

class BookmarkListPage extends StatefulWidget {
  BookmarkListPage({super.key});

  @override
  State<BookmarkListPage> createState() => _BookmarkListPageState();
  List<String> selectedTags = [];
}

class _BookmarkListPageState extends State<BookmarkListPage> {
  /*
  void updatePosition(Location location) async {
    Position position = await getPosition();
    location.accuracy = position.accuracy;
    location.altitude = position.altitude;
    location.latitude = position.latitude;
    location.longitude = position.longitude;
    location.timestamp = DateTime.now();
  }

  void showSettingsPage(BuildContext context, LocationProvider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: const Text("Settings")),
            body: ExportWidget(
              name: 'location_list',
              toJson: provider.toJson,
              fromJson: provider.fromJson,
              clearJson: provider.clear,
            ),
          );
        },
      ),
    );
  }
*/
  void setSelected(List<dynamic> selectedItems)
  {
    setState(() {
      widget.selectedTags = selectedItems.cast<String>();

    });
  }
  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = context.watch<BookmarkProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Bookmark List"),
        actions: [
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              const PopupMenuItem(value: 1, child: Text("Export")),
              const PopupMenuItem(value: 2, child: Text("File Dir")),
            ],
            elevation: 1,
            onSelected: (value) {
              switch (value) {
                case 1:
                  //showSettingsPage(context, locationProvider);
                  break;
                case 2:
                  selectBookmarkFolder();
                  break;
              }
            },
          ),
        ],
      ),
      body:

      Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Bookmark>>(
              future: bookmarkProvider.getWithTag(widget.selectedTags),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final bookmarks = snapshot.data ?? [];
                if (bookmarks.isEmpty) {
                  return const Center(child: Text('No bookmarks found.'));
                }
                return ListView.builder(
                  itemCount: bookmarks.length,
                  itemBuilder: (context, index) {
                    final reverseIndex = bookmarks.length - 1 - index;
                    return Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookmarkItemPage(
                                item: bookmarks[reverseIndex],
                              ),
                            ),
                          );
                        },
                        title: WidgetBookmark(
                          bookmark: bookmarks[reverseIndex],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.open_in_browser), // The icon on the right
                          onPressed: () {
                            openExternally(bookmarks[reverseIndex].link);
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
              width: double.infinity, // Take the full width of the parent (within padding)
              child: FutureBuilder<List<String>>(
                future: bookmarkProvider.getTags(),
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
                  final tagCards = tags.map((tag) => MultiSelectCard(value: tag, label: tag)).toList();
                  return MultiSelectContainer(
                      showInListView: true,
                      listViewSettings: ListViewSettings(
                          scrollDirection: Axis.horizontal,
                          separatorBuilder: (_, __) => const SizedBox(
                            width: 10,
                          )),
                      items: tagCards,
                      onChange: (allSelectedItems, selectedItem) { setSelected(allSelectedItems);});
                }
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookmarkItemPage(item: Bookmark(), newItem: true,),
            ),
          );
        },
        tooltip: 'Add Location',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class WidgetBookmark extends StatelessWidget {
  final Bookmark bookmark;

  const WidgetBookmark({Key? key, required this.bookmark}) : super(key: key);

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
              style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.surfaceTint),
            ),
            ],
            if (bookmark.comment.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(bookmark.comment, style: const TextStyle(fontSize: 14)),
            ],
            if (bookmark.link.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                bookmark.shortLink(),
                style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.secondaryFixed),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
