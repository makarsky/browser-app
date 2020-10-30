import 'package:json_annotation/json_annotation.dart';
part 'bookmark.g.dart';

@JsonSerializable()
class Bookmark {
  String title;
  String url;

  Bookmark({this.title, this.url});

  factory Bookmark.fromJson(Map<String, dynamic> json) =>
      _$BookmarkFromJson(json);

  Map<String, dynamic> toJson() => _$BookmarkToJson(this);
}
