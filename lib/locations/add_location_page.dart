import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'location.dart';
import 'location_provider.dart';
import '../utils/map.dart';
import '../widgets/export_widget.dart';
import '../widgets/widget_text_input.dart';

class AddLocationPage extends StatefulWidget {
  const AddLocationPage({super.key});

  @override
  State<AddLocationPage> createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {
  late Location location;

  void updatePosition(Location location) async {
    Position position = await getPosition();
    setState(() {
      location.accuracy = position.accuracy;
      location.altitude = position.altitude;
      location.latitude = position.latitude;
      location.longitude = position.longitude;
      location.timestamp = DateTime.now();
    });
  }

  @override
  void initState() {
    super.initState();
    location = Location(
        title: "",
        timestamp: DateTime(2000),
        longitude: 0,
        latitude: 0,
        altitude: 0,
        accuracy: 0);
    updatePosition(location);
  }


  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    String title = "";
    String tags = "";
    bool newItem = true;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Location"),

      ),
      
      body: Column(
        children: [
        WidgetTextInput(
        text: "title",
        hintText: 'Enter title',
        lines: 4,
        onChanged: (value) => title = value,
        //onChanged: (value) => title = value,
        //autofocus: newItem,
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
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children:
            [
              FormattedText(
                  title: "Latitude", content: location.latitude.toString()),
              FormattedText(
                  title: "Longitude",
                  content: location.longitude.toString()),

            ],),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children:
      [

          FormattedText(
              title: "Altitude", content: location.altitude.toString()),
          FormattedText(
              title: "Accuracy",
              content: location.accuracy.round().toString()),
      ],),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  //Navigator.of(context).pop(); // Close the AlertDialog
                  setState(() {
                    updatePosition(location);
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
              if (!newItem)
                TextButton(
                  onPressed: () {
                    locationProvider.delete(location);
                    Navigator.of(context).pop(); // Close the AlertDialog
                  },
                  child: const Text('Delete'),
                ),
              TextButton(
                onPressed: () {
                  location.title = title;
                  location.tags = tags;
                  locationProvider.add(location);
                  Navigator.of(context).pop(); // Close the AlertDialog
                  //}
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
