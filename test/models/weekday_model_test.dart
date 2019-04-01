import 'package:flutter_test/flutter_test.dart';
import 'package:api_client/models/activity_model.dart';
import 'package:api_client/models/enums/weekday_enum.dart';
import 'package:api_client/models/weekday_model.dart';

void main() {
  test('Throws when JSON is null', () {
    const Map<String, dynamic> json = null; // ignore: avoid_init_to_null
    expect(() => WeekdayModel.fromJson(json), throwsFormatException);
  });

  test('Can create from JSON map', () {
    final Map<String, dynamic> pictogramJson = <String, dynamic>{
      'id': 39,
      'lastEdit': '2018-05-17T10:58:41.241292',
      'title': 'cat4',
      'accessLevel': 1,
      'imageUrl': '/v1/pictogram/39/image/raw',
      'imageHash': 'RijAegW2HQR9zaAn8CIUHw=='
    };

    final Map<String, dynamic> activityJson = <String, dynamic>{
      'pictogram': pictogramJson,
      'order': 0,
      'state': 1,
      'id': 1044,
      'isChoiceBoard': false
    };

    final Map<String, dynamic> json = <String, dynamic>{
      'day': 1,
      'activities': <Map<String, dynamic>>[activityJson]
    };

    final WeekdayModel model = WeekdayModel.fromJson(json);
    expect(model.day, Weekday.Monday);
    expect(model.activities.length, 1);
    expect(model.activities[0].toJson(),
        ActivityModel.fromJson(activityJson).toJson());
  });

  test('Can convert to JSON map', () {
    final Map<String, dynamic> pictogramJson = <String, dynamic>{
      'id': 39,
      'lastEdit': '2018-05-17T10:58:41.241292',
      'title': 'cat4',
      'accessLevel': 1,
      'imageUrl': '/v1/pictogram/39/image/raw',
      'imageHash': 'RijAegW2HQR9zaAn8CIUHw=='
    };

    final Map<String, dynamic> activityJson = <String, dynamic>{
      'pictogram': pictogramJson,
      'order': 0,
      'state': 1,
      'id': 1044,
      'isChoiceBoard': false
    };

    final Map<String, dynamic> json = <String, dynamic>{
      'day': 1,
      'activities': <Map<String, dynamic>>[activityJson]
    };

    final WeekdayModel model = WeekdayModel.fromJson(json);

    expect(model.toJson(), json);
  });
}
