import 'package:api_client/models/model.dart';
import 'package:api_client/offline_repository/repository.dart';
import 'package:api_client/offline_repository/repository_interface.dart';


class TestModel implements Model {
  TestModel(this.testName, this.testField);

  TestModel.fromJson(Map<String, dynamic> json) {
    testName = json['testName'];
    testField = json['testField'];
    offlineId = json['offlineId'];
  }

  String testName;

  String testField;

  int offlineId;

  @override
  /// Get offline id
  int getOfflineId() {
    return offlineId;
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'testName': testName,
      'testField': testField,
      'offlineId': offlineId,
    };
  }

  /// getter for repository
  static IOfflineRepository<Model> offline() {
    return OfflineRepository((TestModel).toString());
  }

}
