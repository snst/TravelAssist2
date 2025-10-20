import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/travel_assist_utils.dart';
import 'bookmark.dart';
import 'bookmark_item_page.dart';
import 'bookmark_provider.dart';

class BookmarkListPage extends StatefulWidget {
  const BookmarkListPage({super.key});

  @override
  State<BookmarkListPage> createState() => _BookmarkListPageState();
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
      body: ListView.builder(
        itemCount: bookmarkProvider.items.length,
        itemBuilder: (context, index) {
          final reverseIndex = bookmarkProvider.items.length - 1 - index;
          return Card(
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookmarkItemPage(
                      item: bookmarkProvider.items[reverseIndex],
                    ),
                  ),
                );
              },
              title: WidgetBookmark(
                bookmark: bookmarkProvider.items[reverseIndex],
              ),
              trailing: IconButton(
                icon: Icon(Icons.open_in_browser), // The icon on the right
                onPressed: () {
                  openExternally(bookmarkProvider.items[reverseIndex].link);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookmarkItemPage(item: Bookmark()),
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
            if (bookmark.title.isNotEmpty) ...[
              SizedBox(height: 2),
              Text(bookmark.title, style: TextStyle(fontSize: 14)),
            ],
            if (bookmark.link.isNotEmpty) ...[
              SizedBox(height: 2),
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
