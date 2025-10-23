import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../utils/map.dart';
import '../widgets/widget_item_edit_actions.dart';
import '../widgets/widget_text_input.dart';
import '../widgets/widget_tags.dart';
import 'location.dart';
import 'location_provider.dart';

class LocationItemPage extends StatefulWidget {
  LocationItemPage({super.key, this.modifiedItem});

  @override
  State<LocationItemPage> createState() => _LocationItemPageState();
  Location? modifiedItem;
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
    if (widget.modifiedItem == null) {
      widget.newItem = true;
      widget.modifiedItem = Location(
        title: "",
        timestamp: DateTime(2000),
        longitude: 0,
        latitude: 0,
        altitude: 0,
        accuracy: 0,
      );
      updatePosition(widget.modifiedItem!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    String title = widget.modifiedItem!.title;
    String tags = widget.modifiedItem!.tags;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Location"),
      ),

      body: Column(
        children: [
          SizedBox(height: 5),
          WidgetTextInput(
            text: title,
            hintText: 'Enter Location',
            lines: 4,
            onChanged: (value) => title = value,
            autofocus: widget.newItem,
          ),
          SizedBox(height: 5),
          /*WidgetTextInput(
            text: tags,
            hintText: 'Enter Info',
            onChanged: (value) => tags = value,
          ),*/
          //WidgetTags(),
          SizedBox(height: 5),
          TextField(
            controller: TextEditingController()
              ..text = widget.modifiedItem!.comment,
            decoration: const InputDecoration(hintText: 'Comment'),
            onChanged: (value) => widget.modifiedItem!.comment = value,
            keyboardType: TextInputType.multiline,
            minLines: 3,
            //Normal textInputField will be displayed
            maxLines: 3, // when user presses enter it will adapt to it
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FormattedText(
                title: "Latitude, Longitude",
                content:
                    "${widget.modifiedItem!.latitude.toString()}, ${widget.modifiedItem!.longitude.toString()}",
              ),
              ElevatedButton(
                child: const Text('Map'),
                onPressed: () {
                  //Navigator.of(context).pop(); // Close the AlertDialog
                  launchMapOnAndroid(
                    widget.modifiedItem!.latitude,
                    widget.modifiedItem!.longitude,
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
                content: widget.modifiedItem!.getDateTimeStr(),
              ),
              FormattedText(
                title: "Accuracy",
                content: widget.modifiedItem!.accuracy.round().toString(),
              ),
              FormattedText(
                title: "Altitude",
                content: widget.modifiedItem!.altitude.toStringAsFixed(1),
              ),
            ],
          ),
          Row(
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [/*
              ElevatedButton(
                child: const Text('Refresh'),
                onPressed: () {
                  setState(() {
                    updatePosition(widget.location!);
                  });
                },
              ),*/


            ],
          ),
          WidgetItemEditActions(
            onSave: () {
              widget.modifiedItem!.title = title;
              widget.modifiedItem!.tags = tags;
              locationProvider.add(widget.modifiedItem!);
              return true;
            },
            onDelete: (widget.newItem)
                ? null
                : () {
              locationProvider.delete(widget.modifiedItem!);
            },
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
