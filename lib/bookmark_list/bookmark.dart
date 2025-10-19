import 'package:isar_community/isar.dart';

// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';
part 'bookmark.g.dart';

@collection
@JsonSerializable()
class Bookmark {
  Bookmark(
      {this.title = ""});

  @JsonKey(includeFromJson: false, includeToJson: false)
  Id id = Isar.autoIncrement;
  String title;
  List<String> tags = [];
  List<String> links = [];


  factory Bookmark.fromJson(Map<String, dynamic> json) =>
      _$BookmarkFromJson(json);

  Map<String, dynamic> toJson() => _$BookmarkToJson(this);
}
