import 'package:meta/meta.dart';
import 'package:api_client/models/enums/access_level_enum.dart';
import 'package:api_client/models/model.dart';
import 'package:tuple/tuple.dart';

class PictogramModel implements Model {

  /// Constructor
  PictogramModel({
    this.id,
    this.lastEdit,
    @required this.title,
    @required this.accessLevel,
    this.imageUrl,
    this.imageHash,
    this.userId,
    this.alternativeTitleRelations,
  });

  PictogramModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw const FormatException(
          '[PictogramModel]: Cannot initialize from null');
    }

    id = json['id'];
    lastEdit =
      json['lastEdit'] == null ? null : DateTime.tryParse(json['lastEdit']);
    title = json['title'];
    accessLevel = AccessLevel.values[(json['accessLevel']) - 1];
    imageUrl = json['imageUrl'];
    imageHash = json['imageHash'];
    userId = json['userId'];
    alternativeTitleRelations = json['alternativeTitleRelations'];
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

  String userId;

  /// The alternative title of the pictogram, in relation to the citizen.
  List<Tuple2<String, String>> alternativeTitleRelations =
                                              <Tuple2<String, String>>[];



  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = <String, dynamic>{
      'title': title,
      'accessLevel': accessLevel.index + 1,
    };

    if (id != 0) {
      result['id'] = id;
    }

    if (lastEdit != null) {
      result['lastEdit'] = lastEdit.toIso8601String();
    }

    if (imageUrl != null) {
      result['imageUrl'] = imageUrl;
    }

    if (imageHash != null) {
      result['imageHash'] = imageHash;
    }

    if(userId != null){
      result['userId'] = userId;
    }

    if(alternativeTitleRelations != null){
      result['alternativeTitleRelations'] = alternativeTitleRelations;
    }

    return result;
  }
}
