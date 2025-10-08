import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'location.dart';
import 'location_provider.dart';
import '../utils/map.dart';
import '../widgets/widget_text_input.dart';

class LocationPage extends StatefulWidget {
  LocationPage({super.key, this.location});

  @override
  State<LocationPage> createState() => _LocationPageState();
  Location? location;
  bool newItem = false;
}

class _LocationPageState extends State<LocationPage> {
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
        title: widget.newItem
            ? const Text("Add Location")
            : const Text("Edit Location"),
      ),

      body: Column(
        children: [
          WidgetTextInput(
            text: title,
            hintText: 'Enter title',
            lines: 4,
            onChanged: (value) => title = value,
            autofocus: widget.newItem,
          ),
          SizedBox(height: 5),
          WidgetTextInput(
            text: tags,
            hintText: 'Enter tags',
            onChanged: (value) => tags = value,
          ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (!widget.newItem)
            IconButton(
              iconSize: 48,
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm Delete'),
                      content: const Text(
                          'Are you sure you want to delete this location?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('No'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          child: const Text('Yes'),
                          onPressed: () {
                            locationProvider.delete(widget.location!);
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              //const Text('Delete'),
            ),
          IconButton(
            iconSize: 48,
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop(); // Close the AlertDialog
            },
          ),
          IconButton(
            iconSize: 48,
            icon: const Icon(Icons.save),
            onPressed: () {
              widget.location!.title = title;
              widget.location!.tags = tags;
              locationProvider.add(widget.location!);
              Navigator.of(context).pop();
            },
            //const Text('OK'),
          ),
        ]),

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
          IconButton(
            iconSize: 48,
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                updatePosition(widget.location!);
              });
            },
          ),
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FormattedText(
                title: "Latitude, Longitude",
                content: "${widget.location!.latitude.toString()}, ${widget.location!.longitude.toString()}",
              ),
              FormattedText(
                title: "Altitude",
                content: widget.location!.altitude.toString(),
              ),
              IconButton(
                iconSize: 48,
                icon: const Icon(Icons.map),
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
