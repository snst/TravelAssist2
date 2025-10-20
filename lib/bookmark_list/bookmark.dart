import 'package:isar_community/isar.dart';

// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';
part 'bookmark.g.dart';

@collection
@JsonSerializable()
class Bookmark {
  Bookmark(
      {this.link = ""});

  @JsonKey(includeFromJson: false, includeToJson: false)
  Id id = Isar.autoIncrement;
  String title="";
  String comment="";
  String link;
  List<String> tags = [];


  String shortLink() {
    if (link.startsWith("/")) {
      return ".." + link.substring(link.length-25);
    } else if (link.startsWith("https://")) {
      return link.substring(8);
    } else if (link.startsWith("http://")) {
      return link.substring(7);
    }
    return link;
  }

  Bookmark clone() {
    var item = Bookmark();
    item.update(this);
    return item;
  }

  void update(Bookmark other) {
    id = other.id;
    title = other.title;
    comment = other.comment;
    link = other.link;
    tags = other.tags.toList();
  }

  @override
  String toString() {
    return 'Bookmark{title: $title, tags: $tags, link: $link}';
  }


  factory Bookmark.fromJson(Map<String, dynamic> json) =>
      _$BookmarkFromJson(json);

  Map<String, dynamic> toJson() => _$BookmarkToJson(this);
}
