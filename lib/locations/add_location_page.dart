import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'location.dart';
import 'location_provider.dart';
import '../utils/map.dart';
import '../widgets/widget_text_input.dart';

class AddLocationPage extends StatefulWidget {
  AddLocationPage({super.key, this.location});

  @override
  State<AddLocationPage> createState() => _AddLocationPageState();
  Location? location;
  bool newItem = false;
}

class _AddLocationPageState extends State<AddLocationPage> {
  //late Location location;

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
          accuracy: 0);
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
        title: widget.newItem ? const Text("Add Location")  : const Text("Edit Location"),

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
          TextButton(
            onPressed: () {
              //Navigator.of(context).pop(); // Close the AlertDialog
              launchMapOnAndroid(widget.location!.latitude, widget.location!.longitude);
            },
            child: const Text('Open Map'),
          ),
          FormattedText(
              title: "Time", content: widget.location!.getDateTimeStr()),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children:
            [
              FormattedText(
                  title: "Latitude", content: widget.location!.latitude.toString()),
              FormattedText(
                  title: "Longitude",
                  content: widget.location!.longitude.toString()),

            ],),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children:
      [

          FormattedText(
              title: "Altitude", content: widget.location!.altitude.toString()),
          FormattedText(
              title: "Accuracy",
              content: widget.location!.accuracy.round().toString()),
      ],),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  //Navigator.of(context).pop(); // Close the AlertDialog
                  setState(() {
                    updatePosition(widget.location!);
                  });
                },
                child: const Text('Update Position'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the AlertDialog
                },
                child: const Text('Cancel'),
              ),
              if (!widget.newItem)
                TextButton(
                  onPressed: () {
                    locationProvider.delete(widget.location!);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Delete'),
                ),
              TextButton(
                onPressed: () {
                  widget.location!.title = title;
                  widget.location!.tags = tags;
                  locationProvider.add(widget.location!);
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ]),
      
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
