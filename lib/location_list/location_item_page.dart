import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../utils/map.dart';
import '../widgets/widget_comment.dart';
import '../widgets/widget_item_edit_actions.dart';
import '../widgets/widget_tags.dart';
import 'location.dart';
import 'location_provider.dart';

class LocationItemPage extends StatefulWidget {
  LocationItemPage({super.key, required this.item, this.newItem = false})
  : modifiedItem = item.clone();

  @override
  State<LocationItemPage> createState() => _LocationItemPageState();
  final Location item;
  final Location modifiedItem;
  final bool newItem;
}

class _LocationItemPageState extends State<LocationItemPage> {
  late StringTagController _stringTagController;
  List<String> _initialTags = [];

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
    _stringTagController = StringTagController();

    if (widget.newItem) {
      updatePosition(widget.modifiedItem);
    }
  }


  @override
  void dispose() {
    super.dispose();
    _stringTagController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    if (_initialTags.isEmpty) {
      _initialTags = locationProvider.getTags();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Location"),
      ),

      body: Column(
        children: [
          SizedBox(height: 5),
          WidgetTags(
            allTags: _initialTags,
            tags: widget.modifiedItem.tags,
            stringTagController: _stringTagController,
          ),
          SizedBox(height: 5),
          WidgetComment(comment: widget.modifiedItem.comment, onChanged: (value) => widget.modifiedItem.comment = value),


          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FormattedText(
                title: "Latitude, Longitude",
                content:
                    "${widget.modifiedItem.latitude.toString()}, ${widget.modifiedItem.longitude.toString()}",
              ),
              ElevatedButton(
                child: const Text('Map'),
                onPressed: () {
                  //Navigator.of(context).pop(); // Close the AlertDialog
                  launchMapOnAndroid(
                    widget.modifiedItem.latitude,
                    widget.modifiedItem.longitude,
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
                content: widget.modifiedItem.getDateTimeStr(),
              ),
              FormattedText(
                title: "Accuracy",
                content: widget.modifiedItem.accuracy.round().toString(),
              ),
              FormattedText(
                title: "Altitude",
                content: widget.modifiedItem.altitude.toStringAsFixed(1),
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
              widget.item.update(widget.modifiedItem);
              locationProvider.add(widget.item);
              return true;
            },
            onDelete: (widget.newItem)
                ? null
                : () {
              locationProvider.delete(widget.item);
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
