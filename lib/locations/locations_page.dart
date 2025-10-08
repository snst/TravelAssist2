import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'location.dart';
import 'location_provider.dart';
import 'add_location_page.dart';
import '../utils/map.dart';
import '../widgets/export_widget.dart';
import '../widgets/widget_text_input.dart';

class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key});

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  void updatePosition(Location location) async {
    Position position = await getPosition();
    location.accuracy = position.accuracy;
    location.altitude = position.altitude;
    location.latitude = position.latitude;
    location.longitude = position.longitude;
    location.timestamp = DateTime.now();
  }

  void showSettingsPage(BuildContext context, LocationProvider provider) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Scaffold(
          appBar: AppBar(
            title: const Text("Settings"),
          ),
          body: ExportWidget(
            name: 'locations',
            toJson: provider.toJson,
            fromJson: provider.fromJson,
            clearJson: provider.clear,
          ));
    }));
  }

  Future<void> _showEditDialog(BuildContext context, LocationProvider provider,
      Location location, bool newItem) async {
    String title = location.title;
    String tags = location.tags;

    if (newItem) {
      updatePosition(location);
    }

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Location'),
            content: SingleChildScrollView(
              reverse: false,
              child: Column(
                children: [
                  WidgetTextInput(
                    text: title,
                    hintText: 'Enter title',
                    lines: 4,
                    onChanged: (value) => title = value,
                    autofocus: newItem,
                  ),
                  SizedBox(height: 5),
                  WidgetTextInput(
                    text: tags,
                    hintText: 'Enter tags',
                    onChanged: (value) => tags = value,
                  ),
                  TextButton(
                    onPressed: () {
                      //Navigator.of(context).pop(); // Close the AlertDialog
                      launchMapOnAndroid(location.latitude, location.longitude);
                    },
                    child: const Text('Open Map'),
                  ),
                  FormattedText(
                      title: "Time", content: location.getDateTimeStr()),
                  FormattedText(
                      title: "Latitude", content: location.latitude.toString()),
                  FormattedText(
                      title: "Longitude",
                      content: location.longitude.toString()),
                  FormattedText(
                      title: "Altitude", content: location.altitude.toString()),
                  FormattedText(
                      title: "Accuracy",
                      content: location.accuracy.round().toString()),
                  TextButton(
                    onPressed: () {
                      //Navigator.of(context).pop(); // Close the AlertDialog
                      setState(() {
                        updatePosition(location);
                      });
                    },
                    child: const Text('Update Position'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the AlertDialog
                },
                child: const Text('Cancel'),
              ),
              if (!newItem)
                TextButton(
                  onPressed: () {
                    provider.delete(location);
                    Navigator.of(context).pop(); // Close the AlertDialog
                  },
                  child: const Text('Delete'),
                ),
              TextButton(
                onPressed: () {
                  location.title = title;
                  location.tags = tags;
                  provider.add(location);
                  Navigator.of(context).pop(); // Close the AlertDialog
                  //}
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Locations"),
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
                  showSettingsPage(context, locationProvider);
                  break;
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
          itemCount: locationProvider.items.length,
          itemBuilder: (context, index) {
            final reverseIndex = locationProvider.items.length - 1 - index;
            return Card(
              child: ListTile(
                onTap: () {
                  _showEditDialog(context, locationProvider,
                      locationProvider.items[reverseIndex], false);
                },
                title: FormattedText(
                    title:
                    locationProvider.items[reverseIndex].getDateTimeStr(),
                    content: locationProvider.items[reverseIndex].title),
                trailing: IconButton(
                  icon: Icon(Icons.map), // The icon on the right
                  onPressed: () {
                    launchMapOnAndroid(
                        locationProvider.items[reverseIndex].latitude,
                        locationProvider.items[reverseIndex].longitude);
                  },
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddLocationPage()),
          );
        },
        tooltip: 'Add Location',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class FormattedText extends StatelessWidget {
  final String title;
  final String content;

  const FormattedText({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

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