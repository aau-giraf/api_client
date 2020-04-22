import 'package:api_client/models/activity_model.dart';
import 'package:api_client/models/model.dart';
import 'package:api_client/models/username_model.dart';

/// Model factory for the database
class ModelFactory {

  /// Method for getting correct model
  static Model getModel(Map<String, dynamic> json, String tableName) {
    if (tableName == 'username') {
      return UsernameModel.fromJson(json);
    } else if (tableName == 'activity') {
      return ActivityModel.fromJson(json);
    }
    return null;
  }
}
