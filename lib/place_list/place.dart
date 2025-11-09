import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
// ignore: depend_on_referenced_packages
import 'package:json_annotation/json_annotation.dart';

import '../utils/globals.dart';
import '../utils/storage_item.dart';
import '../utils/travel_assist_utils.dart';

part 'place.g.dart';

enum PlaceStateEnum { dynamic, fixed, booked, placeholder }

@collection
@JsonSerializable()
class Place implements StorageItem {
  Place({this.title = "", DateTime? timestamp, this.nights = 0})
    : date = timestamp ?? DateTime.now();

  @JsonKey(includeFromJson: false, includeToJson: false)
  Id id = Isar.autoIncrement;
  String title;
  int nights;
  DateTime date;
  @enumerated
  PlaceStateEnum state = PlaceStateEnum.dynamic;
  String comment = "";
  String link1 = "";
  String link2 = "";
  String link3 = "";

  @JsonKey(includeFromJson: false, includeToJson: false)
  @ignore
  bool isDirty = false;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @ignore
  bool hasError = false;

  bool isLocked() => state == PlaceStateEnum.fixed;

  bool isBooked() => state == PlaceStateEnum.booked;

  bool isPlaceholder() => state == PlaceStateEnum.placeholder;

  bool isDynamic() => !isLocked() && !isBooked();

  Color? getCardColor() {
    if (isPlaceholder()) {
      return Colors.blueGrey.shade700;
    } else if (hasError) {
      return Colors.deepOrange.shade700;
    }
    return null;
  }

  IconData getStateIcon() {
    switch (state) {
      case PlaceStateEnum.dynamic:
        return PlaceIcons.dynamic;
      case PlaceStateEnum.fixed:
        return PlaceIcons.fixed;
      case PlaceStateEnum.booked:
        return PlaceIcons.booked;
      case PlaceStateEnum.placeholder:
        return PlaceIcons.placeholder;
    }
  }

  void setDate(DateTime date) {
    if (this.date != date) {
      this.date = date;
      isDirty = true;
    }
  }

  void decDate(int days) {
    setDate(date.subtract(Duration(days: days)));
  }

  void incDate(int days) {
    setDate(date.add(Duration(days: days)));
  }

  void setNights(int nights) {
    if (this.nights != nights) {
      this.nights = nights;
      isDirty = true;
    }
  }

  String getDateTimeStr() => formatDate(date);

  String getTimespan() {
    if (nights < 1) {
      return getDateTimeStr();
    } else {
      DateTime end = date.add(Duration(days: nights));
      return "${getDateTimeStr()}  -  ${formatDate(end)}";
    }
  }

  DateTime getStartDate() => date;

  DateTime getEndDate() => date.add(Duration(days: nights));

  void switchDate(Place other) {
    var tmp = getStartDate();
    setDate(other.getStartDate());
    other.setDate(tmp);
  }

  void moveUp(Place other) {
    if (isLocked()) {
      decDate(1);
    } else if (other.isDynamic()) {
      switchDate(other);
    } else if (!other.isPlaceholder()) {
      setDate(other.getStartDate().subtract(Duration(days: 1)));
    }
  }

  void moveDown(Place other) {
    if (isLocked()) {
      incDate(1);
    } else if (other.isDynamic()) {
      switchDate(other);
    } else if (!other.isPlaceholder()) {
      setDate(other.getStartDate().add(Duration(days: 1)));
    }
  }

  Place clone() {
    var item = Place();
    item.update(this);
    return item;
  }

  void update(Place other) {
    id = other.id;
    nights = other.nights;
    state = other.state;
    comment = other.comment;
    title = other.title;
    date = other.date;
    link1 = other.link1;
    link2 = other.link2;
    link3 = other.link3;
  }

  @override
  Id getId() {
    return id;
  }

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);

  Map<String, dynamic> toJson() => _$PlaceToJson(this);
}
