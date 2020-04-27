import 'package:api_client/models/model.dart';
import 'package:api_client/offline_repository/repository.dart';
import 'package:api_client/offline_repository/repository_interface.dart';

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

  /// Offline id
  int offlineId;

  @override
  /// Get offline id
  int getOfflineId() {
    return offlineId;
  }

  @override
  /// Offline id
  int offlineId;

  @override
  /// Get offline id
  int getOfflineId() {
    return offlineId;
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
  };

  /// getter for repository
  static IOfflineRepository<Model> offline() {
    return OfflineRepository((DepartmentNameModel).toString());
  }
}
