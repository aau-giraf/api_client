import 'package:api_client/models/model.dart';
import 'package:api_client/models/enums/role_enum.dart';
import 'package:api_client/offline_repository/repository.dart';
import 'package:api_client/offline_repository/repository_interface.dart';

class GirafUserModel implements Model {
  /// Constructor for instantiating a user inside the app.
  GirafUserModel(
      {this.id,
      this.role,
      this.roleName,
      this.username,
      this.screenName,
      this.department});

  /// Constructor for instantiating a user from the backend response.
  GirafUserModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw const FormatException(
          '[GirafUserModel]: Cannot initialize from null');
    }

    id = json['id'];
    role = Role.values[(json['role']) - 1];
    roleName = json['roleName'];
    username = json['username'];
    screenName = json['screenName'];
    department = json['department'];
  }

  /// The id of the user
  String id;

  /// The role of the user
  Role role;

  /// The name of the role
  String roleName;

  /// The username
  String username;

  /// The users desired "screen name", i.e. how the app should address the user.
  String screenName;

  // This is actually a long from the .Net server, will that cause problems?
  // (try with mInt).
  /// The id of the users department
  int department;

  /// Converts the user object to json, inorder to send it to the backend.
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'role': role.index + 1,
      'roleName': roleName,
      'username': username,
      'screenName': screenName,
      'department': department
    };
  }

  /// getter for repository
  static IOfflineRepository<Model> offline() {
    return OfflineRepository((GirafUserModel).toString());
  }
}
