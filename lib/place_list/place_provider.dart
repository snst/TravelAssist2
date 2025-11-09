import 'dart:convert';

import '../utils/globals.dart';
import '../utils/json_export.dart';
import '../utils/storage.dart';
import 'place.dart';

class PlaceProvider extends Storage<Place> implements JsonExport {
  PlaceProvider(super.isar);

  List<Place> getSortedPlaces(List<Place> places) {
    places.sort((a, b) => a.date.compareTo(b.date));
    return places;
  }

  void saveDirty(List<Place> places) {
    for (var place in places) {
      if (place.isDirty && !place.isPlaceholder()) {
        add(place);
        place.isDirty = false;
      }
    }
  }

  String getTitle(List<Place> places) {
    if (places.isEmpty) return Txt.places;
    final firstDate = places.first.getStartDate();
    final lastDate = places.last.getEndDate();
    var now = DateTime.now();
    var nowDay = DateTime(now.year, now.month, now.day);
    var days1 = nowDay.difference(firstDate).inDays.abs();
    var days2 = nowDay.difference(lastDate).inDays.abs();
    var nights = lastDate.difference(firstDate).inDays;
    if (nowDay.isBefore(firstDate)) {
      return "$days1 waiting ($nights nights)";
    } else if (nowDay.isAfter(lastDate)) {
      return "${days2} after ($nights nights)";
    } else {
      return "${days1} + $days2 = $nights nights";
    }
  }

  List<Place> getPlaces(List<Place> places) {
    var tmp = getSortedPlaces(places);
    if (tmp.isEmpty) return [];

    final result = <Place>[];
    result.add(tmp.first);

    for (int i = 0; i < tmp.length - 1; i++) {
      final current = tmp[i];
      final next = tmp[i + 1];
      if (next.isDynamic()) {
        next.setDate(current.getEndDate());
      }

      // If there is a gap between the end of the next place and the start of the current one
      if (current.getEndDate().isBefore(next.getStartDate())) {
        var p = Place(
          title: "",
          timestamp: current.getEndDate(),
          nights: next.getStartDate().difference(current.getEndDate()).inDays,
        );
        p.state = PlaceStateEnum.placeholder;
        p.title = p.nights == 1 ? "${p.nights} night to plan" : "${p.nights} nights to plan";
        result.add(p); // Add a placeholder for the gap
      }
      result.add(next);
    }

    for (var p in result) {
      p.hasError = false;
    }

    for (int i = 0; i < result.length - 1; i++) {
      final current = result[i];
      final next = result[i + 1];
      if (current.getEndDate() != next.getStartDate()) {
        current.hasError = true;
        //next.hasError = true;
      }
    }
    //saveDirty(result);
    return result;
  }

  @override
  Future<String> toJson() async {
    final all = await getAll();
    List<Map<String, dynamic>> jsonList = all.map((item) => item.toJson()).toList();
    return jsonEncode(jsonList);
  }

  @override
  void fromJson(String? jsonString, bool append) {
    if (jsonString != null) {
      if (!append) {
        clear();
      }
      final jsonList = jsonDecode(jsonString) as List;
      for (var json in jsonList) {
        add(Place.fromJson(json), notify: false);
      }
      notifyListeners();
    }
  }
}
