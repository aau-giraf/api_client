import 'package:api_client/offline_repository/repository.dart';
import 'package:api_client/offline_repository/repository_interface.dart';
import 'package:meta/meta.dart';
import 'package:api_client/models/model.dart';
import 'package:api_client/models/displayname_model.dart';

class DepartmentModel implements Model {
  /// Default constructor
  DepartmentModel({
    @required this.id,
    @required this.name,
    @required this.members,
    @required this.resources,
  });

  /// Constructs from JSON
  DepartmentModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw const FormatException(
          '[DepartmentModel]: Cannot instantiate from null');
    }

    id = json['id'];
    name = json['name'];
    members = (json['members'] is List
            ? List<Map<String, dynamic>>.from(json['members'])
            : null)
        .map((Map<String, dynamic> value) => DisplayNameModel.fromJson(value))
        .toList();
    resources =
        json['resources'] is List ? List<int>.from(json['resources']) : null;
  }

  /// The id of the department.
  int id;

  /// The name of the department.
  String name;

  /// A list of the user names of all members of the department.
  List<DisplayNameModel> members = <DisplayNameModel>[];

  /// A list of ids of all resources owned by the department.
  List<int> resources = <int>[];

  @override
  /// Offline id
  int offlineId;

  @override
  /// Get offline id
  int getOfflineId() {
    return offlineId;
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'members':
          members.map((DisplayNameModel member) => member.toJson()).toList(),
      'resources': resources
    };
  }

  /// getter for repository
  static IOfflineRepository<Model> offline() {
    return OfflineRepository((DepartmentModel).toString());
  }
}
