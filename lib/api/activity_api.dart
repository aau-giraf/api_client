import 'package:api_client/http/http.dart';
import 'package:api_client/models/activity_model.dart';
import 'package:rxdart/rxdart.dart';

/// Pictogram endpoints
class ActivityApi {
  /// Default constructor
  ActivityApi(this._http);

  final Http _http;

  /// Read the pictogram with the specified id id and check if the user is
  /// authorized to see it.
  ///
  /// [id] Id of pictogram to get
  Observable<ActivityModel> update(ActivityModel activity) {
    return _http.put('/update', activity.toJson()).map((Response res) {
      return ActivityModel.fromJson(res.json['data']);
    });
  }
}
