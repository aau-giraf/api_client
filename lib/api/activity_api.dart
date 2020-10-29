import 'package:api_client/http/http.dart';
import 'package:api_client/models/activity_model.dart';
import 'package:api_client/models/enums/weekday_enum.dart';
import 'package:api_client/offline_database/offline_db_handler.dart';

/// Pictogram endpoints
class ActivityApi {
  /// Default constructor
  ActivityApi(this._http);

  final Http _http;

  /// Adds the specified activity
  ///
  /// [activity] Activity to add.
  /// [userId] User ID
  /// [weekplanName] Name of the week plan
  /// [weekYear] Year of the week
  /// [weekNumber] Week number of the week
  /// [weekDay] Day of the week that the activity should be added to
  Stream<ActivityModel> add(ActivityModel activity, String userId,
      String weekplanName, int weekYear, int weekNumber, Weekday weekDay) {
    return _http
        .post(
            '/$userId/$weekplanName/$weekYear/$weekNumber/${weekDay.index + 1}',
            activity.toJson())
        .asyncMap((Response res) {
      if (res.success()) {
        OfflineDbHandler.instance.addActivity(
            activity, userId, weekplanName, weekYear, weekNumber, weekDay);
        return ActivityModel.fromJson(res.json['data']);
      } else {
        return OfflineDbHandler.instance.addActivity(
            activity, userId, weekplanName, weekYear, weekNumber, weekDay);
      }
    });
  }

  /// Updates the activity with the specified ID
  ///
  /// [activity] Activity with an id that updates values in the database
  /// [userId] User ID
  Stream<ActivityModel> update(ActivityModel activity, String userId) {
    return _http
        .patch('/$userId/update', activity.toJson())
        .asyncMap((Response res) {
      if (res.success()) {
        OfflineDbHandler.instance.updateActivity(activity, userId);
        return ActivityModel.fromJson(res.json['data']);
      } else {
        return OfflineDbHandler.instance.updateActivity(activity, userId);
      }
    });
  }

  /// Deletes the activity with the specified ID
  ///
  /// [activityId] ID of the activity to delete
  /// [userID] User ID
  Stream<bool> delete(int activityId, String userId) {
    return _http.delete('/$userId/delete/$activityId').asyncMap((Response res) {
      if (res.success()) {
        OfflineDbHandler.instance.deleteActivity(activityId, userId);
        return res.success();
      } else {
        return OfflineDbHandler.instance.deleteActivity(activityId, userId);
      }
    });
  }
}
