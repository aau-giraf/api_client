import 'package:api_client/http/http.dart';
import 'package:api_client/models/activity_model.dart';
import 'package:rxdart/rxdart.dart';

/// Pictogram endpoints
class ActivityApi {
  /// Default constructor
  ActivityApi(this._http);

  final Http _http;

  /// Updates the activity with the specified id 
  ///
  /// [id] Activity with a id that updates values in the database
  Observable<ActivityModel> update(ActivityModel activity, String userId) {
    return _http.patch('/$userId/update', activity.toJson()).map((Response res) {
      return ActivityModel.fromJson(res.json['data']);
    });
  }
}
