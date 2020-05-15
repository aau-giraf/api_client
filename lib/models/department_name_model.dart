import 'package:api_client/models/model.dart';

class DepartmentNameModel implements Model {
  DepartmentNameModel({this.id, this.name});

  DepartmentNameModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw const FormatException(
          '[DepartmentNameModel]: Cannot instantiate from null');
    }

    id = json['id'];
    name = json['name'];
  }

  /// The id of the department.
  int id;

  /// The name of the department.
  String name;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
  };

}
