import 'package:api_client/models/activity_model.dart';
import 'package:api_client/models/model.dart';
import 'package:api_client/models/username_model.dart';

/// Model factory for the database
class ModelFactory {

  /// Method for getting correct model
  static Model getModel(Map<String, dynamic> json, String objectName) {
    if (objectName == (UsernameModel).toString()) {
      return UsernameModel.fromJson(json);
    } else if (objectName == (ActivityModel).toString()) {
      return ActivityModel.fromJson(json);
    }
    return null;
  }
}
