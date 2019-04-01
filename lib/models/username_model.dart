import 'package:meta/meta.dart';
import 'package:api_client/models/model.dart';

class UsernameModel implements Model {
  /// Default constructor
  UsernameModel({@required this.name, @required this.role, @required this.id});

  /// Create object from JSON mapping
  UsernameModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw const FormatException(
          '[UsernameModel]: Cannot instantiate from null');
    }

    id = json['userId'];
    name = json['userName'];
    role = json['userRole'];
  }

  /// The user's name
  String name;

  /// The user's role
  String role;

  /// The user's ID
  String id;

  @override
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'userId': id, 'userName': name, 'userRole': role};
}
