import 'package:isar_community/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'memo.g.dart';

@collection
@JsonSerializable()
class Memo {
  Memo({required this.title, required this.content});

  @JsonKey(includeFromJson: false, includeToJson: false)
  Id id = Isar.autoIncrement;
  String title;
  String content;

  void update(Memo other) {
    id = other.id;
    title = other.title;
    content = other.content;
  }

  Memo clone() {
    var item = Memo(title: "", content: "");
    item.update(this);
    return item;
  }

  factory Memo.fromJson(Map<String, dynamic> json) => _$MemoFromJson(json);

  Map<String, dynamic> toJson() => _$MemoToJson(this);
}
