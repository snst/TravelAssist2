import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

void launchMapOnAndroid(double latitude, double longitude) async {
  try {
    const String markerLabel = 'Here';
    final url = Uri.parse(
      'geo:$latitude,$longitude?q=$latitude,$longitude($markerLabel)',
    );
    await launchUrl(url);
  } catch (error) {
    //if (context.mounted) {
    //Util.showErrorDialog(context: context, error: error.toString());
    //}
  }
}

Future<Position> getPosition() async {
  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  final Position position = await Geolocator.getCurrentPosition(
    locationSettings: locationSettings,
  );
  return position;
}

Future<String> getPositionString() async {
  final Position position = await getPosition();
  return '${position.latitude},${position.longitude}';
}