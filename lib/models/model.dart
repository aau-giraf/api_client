import 'package:api_client/offline_repository/repository_interface.dart';

abstract class Model {
  /// Convert this object to JSON mapping
  Map<String, dynamic> toJson();

  /// The method for getting the repository
  static IOfflineRepository<Model> offline() {
    throw UnimplementedError();
  }

  /// get offline id
  //int getOfflineId();

}