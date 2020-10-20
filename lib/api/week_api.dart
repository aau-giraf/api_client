import 'package:api_client/http/http.dart';
import 'package:api_client/models/week_model.dart';
import 'package:api_client/models/week_name_model.dart';
import 'package:api_client/offline_database/offline_db_handler.dart';


/// Week endpoints
class WeekApi {
  /// Default constructor
  WeekApi(this._http, this.dbHandler);

  final Http _http;
  final OfflineDbHandler dbHandler;

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

  ///Compares a [inputWeekModel] with the offline database and adds
  /// the weekmodel to the offline database if it exists.
  Future<void> hydrateOfflineDbweek(WeekModel inputWeekModel,
      String id, int year, int weekNumber) async{
    WeekModel weekModelOffline = await dbHandler.getWeek(id, year, weekNumber);
    //Compare weekmodels online with offline
    if(inputWeekModel.name == weekModelOffline.name &&
        inputWeekModel.weekNumber == weekModelOffline.weekNumber &&
        inputWeekModel.weekYear == weekModelOffline.weekYear){

    }else{
      //add week to offline database
      dbHandler.updateWeek(id, year, weekNumber, inputWeekModel);
    }

  }

  /// Gets the Week with the specified week number and year for the user with
  /// the given id.
  ///
  /// [id] User ID
  /// [year] Year the week is in
  /// [weekNumber] The week-number of the week
  Stream<WeekModel> get(String id, int year, int weekNumber) {
    return _http.get('/$id/week/$year/$weekNumber').asyncMap((Response res) {
      //if http get success
      if (res.success()) {
        WeekModel weekModelInput = WeekModel.fromJson(res.json['data']);
      //hydrate offline database with week data
        hydrateOfflineDbweek(weekModelInput, id, year, weekNumber);
        return weekModelInput;
      }else{
        // get week from offline database
        return dbHandler.getWeek(id, year, weekNumber);
      }
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
