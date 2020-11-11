import 'package:api_client/http/http.dart';
import 'package:api_client/models/week_model.dart';
import 'package:api_client/models/week_name_model.dart';
import 'package:api_client/models/weekday_model.dart';

/// Week endpoints
class WeekApi {
  /// Default constructor
  WeekApi(this._http);

  final Http _http;

  /// Get week names from the user with the given ID
  ///
  /// [id] User ID
  Stream<List<WeekNameModel>> getNames(String id) {
    return _http.get('/$id/week').map((Response res) {
      if (res.json['data'] is List) {
        return List<Map<String, dynamic>>.from(res.json['data'])
            .map((Map<String, dynamic> json) => WeekNameModel.fromJson(json))
            .toList();
      } else {
        return null;
      }
    });
  }

  /// Gets the Week with the specified week number and year for the user with
  /// the given id.
  ///
  /// [id] User ID
  /// [year] Year the week is in
  /// [weekNumber] The week-number of the week
  Stream<WeekModel> get(String id, int year, int weekNumber) {
    return _http.get('/$id/week/$year/$weekNumber').map((Response res) {
      return WeekModel.fromJson(res.json['data']);
    });
  }

  /// Updates the entire information of the week with the given year and week
  /// number.
  ///
  /// [id] User ID
  /// [year] Year the week is in
  /// [weekNumber] The week-number of the week
  Stream<WeekModel> update(
      String id, int year, int weekNumber, WeekModel week) {
    return _http
        .put('/$id/week/$year/$weekNumber', week.toJson())
        .map((Response res) {
      return WeekModel.fromJson(res.json['data']);
    });
  }

  Stream<WeekdayModel> updateDay(
      String id, int year, int weekNumber, WeekdayModel weekday) {
    return _http
        .patch('/$id/week/$year/$weekNumber', weekday.toJson())
        .map((Response res) {
      return WeekdayModel.fromJson(res.json['data']);
    });
  }

  Stream<WeekModel> patch(
      String id, int year, int weekNumber, WeekModel week) {
    return _http
        .patch('/$id/week/$year/$weekNumber', week.toJson())
        .map((Response res) {
      return WeekModel.fromJson(res.json['data']);
    });
  }

  /// Deletes all information for the entire week with the given year and week
  /// number.
  ///
  /// [id] User ID
  /// [year] Year the week is in
  /// [weekNumber] The week-number of the week
  Stream<bool> delete(String id, int year, int weekNumber) {
    return _http.delete('/$id/week/$year/$weekNumber').map((Response res) {
      return res.success();
    });
  }
}
