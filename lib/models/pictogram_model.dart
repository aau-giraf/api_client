import 'package:meta/meta.dart';
import 'package:api_client/models/enums/access_level_enum.dart';
import 'package:api_client/models/model.dart';

class PictogramModel implements Model {
  PictogramModel({
    this.id,
    this.lastEdit,
    @required this.title,
    @required this.accessLevel,
    this.imageUrl,
    this.imageHash,
  });

  PictogramModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw const FormatException(
          '[PictogramModel]: Cannot initialize from null');
    }

    id = json['id'];
    lastEdit =
        json['lastEdit'] == null ? null : DateTime.parse(json['lastEdit']);
    title = json['title'];
    accessLevel = AccessLevel.values[(json['accessLevel']) - 1];
    imageUrl = json['imageUrl'];
    imageHash = json['imageHash'];
  }

  int id;

  /// The last time the pictogram was edited.
  DateTime lastEdit;

  /// The title of the pictogram.
  String title;

  /// The access level of the pictogram.
  AccessLevel accessLevel;

  String imageUrl;

  String imageHash;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'lastEdit': lastEdit == null ? '' : lastEdit.toIso8601String(),
      'title': title,
      'accessLevel': accessLevel.index + 1,
      'imageUrl': imageUrl,
      'imageHash': imageHash
    };
  }
}
