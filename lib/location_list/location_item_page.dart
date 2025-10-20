import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../utils/map.dart';
import '../widgets/widget_item_edit_actions.dart';
import '../widgets/widget_text_input.dart';
import 'location.dart';
import 'location_provider.dart';

class LocationItemPage extends StatefulWidget {
  LocationItemPage({super.key, this.location});

  @override
  State<LocationItemPage> createState() => _LocationItemPageState();
  Location? location;
  bool newItem = false;
}

class _LocationItemPageState extends State<LocationItemPage> {
  void updatePosition(Location location) async {
    Position position = await getPosition();
    if (mounted) {
      setState(() {
        location.accuracy = position.accuracy;
        location.altitude = position.altitude;
        location.latitude = position.latitude;
        location.longitude = position.longitude;
        location.timestamp = DateTime.now();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.location == null) {
      widget.newItem = true;
      widget.location = Location(
        title: "",
        timestamp: DateTime(2000),
        longitude: 0,
        latitude: 0,
        altitude: 0,
        accuracy: 0,
      );
      updatePosition(widget.location!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    String title = widget.location!.title;
    String tags = widget.location!.tags;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Location"),
      ),

      body: Column(
        children: [
          WidgetTextInput(
            text: title,
            hintText: 'Enter Location',
            lines: 4,
            onChanged: (value) => title = value,
            autofocus: widget.newItem,
          ),
          SizedBox(height: 5),
          WidgetTextInput(
            text: tags,
            hintText: 'Enter Info',
            onChanged: (value) => tags = value,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FormattedText(
                title: "Latitude, Longitude",
                content:
                    "${widget.location!.latitude.toString()}, ${widget.location!.longitude.toString()}",
              ),
              ElevatedButton(
                child: const Text('Map'),
                onPressed: () {
                  //Navigator.of(context).pop(); // Close the AlertDialog
                  launchMapOnAndroid(
                    widget.location!.latitude,
                    widget.location!.longitude,
                  );
                },
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FormattedText(
                title: "Time",
                content: widget.location!.getDateTimeStr(),
              ),
              FormattedText(
                title: "Accuracy",
                content: widget.location!.accuracy.round().toString(),
              ),
              FormattedText(
                title: "Altitude",
                content: widget.location!.altitude.toStringAsFixed(1),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                child: const Text('Refresh'),
                onPressed: () {
                  setState(() {
                    updatePosition(widget.location!);
                  });
                },
              ),
              WidgetItemEditActions(
                onSave: () {
                  widget.location!.title = title;
                  widget.location!.tags = tags;
                  locationProvider.add(widget.location!);
                  return true;
                },
                onDelete: (widget.newItem)
                    ? null
                    : () {
                        locationProvider.delete(widget.location!);
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FormattedText extends StatelessWidget {
  final String title;
  final String content;

  const FormattedText({super.key, required this.title, required this.content});

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
