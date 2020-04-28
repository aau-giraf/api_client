import 'package:api_client/models/activity_model.dart';
import 'package:api_client/models/department_model.dart';
import 'package:api_client/models/department_name_model.dart';
import 'package:api_client/models/displayname_model.dart';
import 'package:api_client/models/giraf_user_model.dart';
import 'package:api_client/models/model.dart';
import 'package:api_client/models/pictogram_model.dart';
import 'package:api_client/models/settings_model.dart';
import 'package:api_client/models/timer_model.dart';
import 'package:api_client/models/week_model.dart';
import 'package:api_client/models/week_name_model.dart';
import 'package:api_client/models/week_template_model.dart';
import 'package:api_client/models/week_template_name_model.dart';
import 'package:api_client/models/weekday_color_model.dart';
import 'package:api_client/models/weekday_model.dart';
import 'package:api_client/offline_repository/exceptions.dart';

/// Model factory for the database
class ModelFactory {

  /// Method for getting correct model
  static Model getModel(Map<String, dynamic> json, String objectName) {
    if (objectName == (DisplayNameModel).toString()) {
      return DisplayNameModel.fromJson(json);
    } else if (objectName == (ActivityModel).toString()) {
      return ActivityModel.fromJson(json);
    } else if (objectName == (PictogramModel).toString()) {
      return PictogramModel.fromJson(json);
    } else if (objectName == (DepartmentModel).toString()) {
      return DepartmentModel.fromJson(json);
    } else if (objectName == (DepartmentNameModel).toString()) {
      return DepartmentNameModel.fromJson(json);
    } else if (objectName == (GirafUserModel).toString()) {
      return GirafUserModel.fromJson(json);
    } else if (objectName == (SettingsModel).toString()) {
      return SettingsModel.fromJson(json);
    } else if (objectName == (TimerModel).toString()) {
      return TimerModel.fromJson(json);
    } else if (objectName == (WeekModel).toString()) {
      return WeekModel.fromJson(json);
    } else if (objectName == (WeekNameModel).toString()) {
      return WeekNameModel.fromJson(json);
    } else if (objectName == (WeekTemplateModel).toString()) {
      return WeekTemplateModel.fromJson(json);
    } else if (objectName == (WeekTemplateNameModel).toString()) {
      return WeekTemplateNameModel.fromJson(json);
    } else if (objectName == (WeekdayColorModel).toString()) {
      return WeekdayColorModel.fromJson(json);
    } else if (objectName == (WeekdayModel).toString()) {
      return WeekdayModel.fromJson(json);
    } else {
      throw NotImplementedInFactory(objectName + ' is not a valid model');
    }
  }
}
