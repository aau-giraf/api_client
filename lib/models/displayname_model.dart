import 'package:api_client/models/giraf_user_model.dart';
import 'package:api_client/offline_repository/repository.dart';
import 'package:api_client/offline_repository/repository_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:api_client/models/model.dart';

class DisplayNameModel implements Model {
  /// Default constructor
  DisplayNameModel({@required this.displayName,
    @required this.role, @required this.id});

  /// Create object from JSON mapping
  DisplayNameModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw const FormatException(
          '[UsernameModel]: Cannot instantiate from null');
    }

    id = json['userId'];
    displayName = json['displayName'];
    role = json['userRole'];
  }

  /// Create object from GirafUserModel
  DisplayNameModel.fromGirafUser(GirafUserModel user) {
    displayName = user.displayName;
    role = user.roleName;
    id = user.id;
  }

  /// The user's displayName
  String displayName;

  /// The user's role
  String role;

  /// The user's ID
  String id;

  /// Offline id
  int offlineId;

  @override
  /// Get offline id
  int getOfflineId() {
    return offlineId;
  }

  @override
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'userId': id,
        'displayName': displayName, 'userRole': role};

  /// getter for repository
  static IOfflineRepository<Model> offline() {
    return OfflineRepository((DisplayNameModel).toString());
  }

}
