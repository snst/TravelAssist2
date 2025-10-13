import 'package:isar_community/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

part 'location.g.dart';

@collection
@JsonSerializable()
class Location {
  Location({
    required this.title,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.accuracy,
    this.comment = "",
    this.tags = "",
  });

  @JsonKey(includeFromJson: false, includeToJson: false)
  Id id = Isar.autoIncrement;
  String title;
  String tags;
  String comment;
  double latitude;
  double longitude;
  double altitude;
  double accuracy;
  DateTime timestamp;

  String getDateTimeStr() => DateFormat.yMd().add_Hm().format(timestamp);

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);
}
