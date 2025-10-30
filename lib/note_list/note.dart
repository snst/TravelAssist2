import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';

import '../utils/globals.dart';
import '../utils/storage_item.dart';

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
      return ".." + link.substring(link.length - 25);
    } else if (link.startsWith("https://")) {
      return link.substring(8);
    } else if (link.startsWith("http://")) {
      return link.substring(7);
    }
    return link;
  }

  Icon getIcon() {
    if (tags.contains(Tag.map)) {
      return MyIcon.map;
    } else if (link.startsWith("geo:")) {
      return MyIcon.gps;
    } else if (link.startsWith("http")) {
      return MyIcon.link;
    } else  {
      return MyIcon.copy;
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

  @override
  Id getId() {
    return id;
  }

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

  Map<String, dynamic> toJson() => _$NoteToJson(this);
}
