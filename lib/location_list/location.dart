import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'location.g.dart';

@collection
@JsonSerializable()
class Location {
  Location();

  @JsonKey(includeFromJson: false, includeToJson: false)
  Id id = Isar.autoIncrement;
  String comment = "";
  double latitude = 0;
  double longitude = 0;
  double altitude = 0;
  double accuracy = 0;
  DateTime timestamp = DateTime.now();
  List<String> tags = [];

  String getDateTimeStr() => DateFormat.yMd().add_Hm().format(timestamp);

  Location clone() {
    var item = Location();
    item.update(this);
    return item;
  }

  void update(Location other) {
    id = other.id;
    comment = other.comment;
    latitude = other.latitude;
    longitude = other.longitude;
    altitude = other.altitude;
    accuracy = other.accuracy;
    timestamp = other.timestamp;
    tags = other.tags.toList();
  }

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);
}
