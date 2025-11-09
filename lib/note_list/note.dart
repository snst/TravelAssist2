import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';

import '../utils/globals.dart';
import '../utils/storage_item.dart';
import '../utils/travel_assist_utils.dart';

part 'note.g.dart';

@collection
@JsonSerializable()
class Note implements StorageItem {
  Note({this.link = "", this.tags = const []});

  @JsonKey(includeFromJson: false, includeToJson: false)
  Id id = Isar.autoIncrement;
  String link;
  String comment = "";
  List<String> tags;
  DateTime timestamp = DateTime.now();

  String getDateTimeStr() => DateFormat.yMd().add_Hm().format(timestamp);

  String shortLink() {
    if (link.startsWith("/")) {
      return "..${link.substring(link.length - 25)}";
    } else if (link.startsWith("https://")) {
      return link.substring(8);
    } else if (link.startsWith("http://")) {
      return link.substring(7);
    }
    return link;
  }

  IconData getIcon() {
    if ((isLink() && tags.contains(Tag.map)) || isGeo()) {
      return MyIcons.map;
    } else if (isLink() || link.startsWith('/')) {
      return MyIcons.link;
    } else {
      return MyIcons.show;
    }
  }

  Note clone() {
    var item = Note();
    item.update(this);
    return item;
  }

  void update(Note other) {
    id = other.id;
    comment = other.comment;
    link = other.link;
    tags = other.tags.toList();
  }

  bool isSame(Note other) {
    if (comment != other.comment) return false;
    if (link != other.link) return false;
    if (tags.toString() != other.tags.toString()) return false;
    if (timestamp != other.timestamp) return false;
    return true;
  }

  @override
  Id getId() => id;

  bool isLink() => isTextLink(link);

  bool isFile() => isTextFile(link);

  bool isGeo() => isTextGeo(link);

  Uri getGeo() => getUriFromGeoString(link);

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

  Map<String, dynamic> toJson() => _$NoteToJson(this);
}
