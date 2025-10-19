import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'bookmark.dart';
import 'bookmark_provider.dart';
//import 'bookmark_item_page.dart';
import '../utils/map.dart';
import '../widgets/export_widget.dart';
import '../widgets/widget_text_input.dart';

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
              //const PopupMenuItem(value: 0, child: Text("Currency rates")),
              const PopupMenuItem(value: 1, child: Text("Settings")),
            ],
            elevation: 1,
            onSelected: (value) {
              switch (value) {
                case 1:
                  //showSettingsPage(context, locationProvider);
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
                // _showEditDialog(context, locationProvider,
                //     locationProvider.items[reverseIndex], false);
                /*Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationItemPage(
                      location: locationProvider.items[reverseIndex],
                    ),
                  ),
                );*/
              },
              title: Text(bookmarkProvider.items[reverseIndex].title)
                  /*
              FormattedText(
                title: locationProvider.items[reverseIndex].getDateTimeStr(),
                content: locationProvider.items[reverseIndex].title,
              )*/
              ,
              trailing: IconButton(
                icon: Icon(Icons.map), // The icon on the right
                onPressed: () {/*
                  launchMapOnAndroid(
                    locationProvider.items[reverseIndex].latitude,
                    locationProvider.items[reverseIndex].longitude,
                  );*/
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {/*
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LocationItemPage()),
          );*/
        },
        tooltip: 'Add Location',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/*
class FormattedText extends StatelessWidget {
  final String title;
  final String content;

  const FormattedText({Key? key, required this.title, required this.content})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title - smaller and grey
            Text(
              title,
              style: TextStyle(
                fontSize: 14, // Smaller font size for title
                color: Colors.grey, // Grey color for title
              ),
            ),
            SizedBox(height: 2), // Spacing between title and content
            // Content - normal text
            Text(
              content,
              style: TextStyle(
                fontSize: 16, // Regular font size for content
                //color: Colors.black, // Default color for content
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/