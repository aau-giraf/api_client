import 'package:api_client/models/giraf_user_model.dart';
import 'package:api_client/offline_repository/repository.dart';
import 'package:api_client/offline_repository/repository_interface.dart';
import 'package:flutter/foundation.dart';
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

  /// Create object from GirafUserModel
  UsernameModel.fromGirafUser(GirafUserModel user) {
    name = user.screenName;
    role = user.roleName;
    id = user.id;
  }

  /// The user's name
  String name;

  /// The user's role
  String role;

  /// The user's ID
  String id;

  @override
  /// Offline id
  int offlineId;

  @override
  /// Get offline id
  int getOfflineId() {
    return offlineId;
  }

  @override
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'userId': id, 'userName': name, 'userRole': role};

  /// getter for repository
  static IOfflineRepository<Model> offline() {
    return OfflineRepository((UsernameModel).toString());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UsernameModel &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              role == other.role &&
              id == other.id;

  @override
  int get hashCode =>
      name.hashCode ^
      role.hashCode ^
      id.hashCode;
}
