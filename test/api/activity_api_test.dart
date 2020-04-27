import 'package:api_client/api/activity_api.dart';
import 'package:api_client/models/activity_model.dart';
import 'package:api_client/models/enums/access_level_enum.dart';
import 'package:api_client/models/enums/activity_state_enum.dart';
import 'package:api_client/models/enums/weekday_enum.dart';
import 'package:api_client/models/pictogram_model.dart';
import 'package:api_client/models/username_model.dart';
import 'package:api_client/models/week_model.dart';
import 'package:api_client/models/weekday_model.dart';
import 'package:api_client/http/http_mock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  HttpMock httpMock;
  ActivityApi activityApi;
  final UsernameModel mockUser =
      UsernameModel(id: '1', name: 'Test', role: 'Guardian');

  final PictogramModel mockPictogram = PictogramModel(
      id: 69,
      title: 'hi',
      accessLevel: AccessLevel.PUBLIC,
      lastEdit: DateTime.now(),
      imageHash: null,
      imageUrl: null);

  final ActivityModel mockActivity = ActivityModel(
      id: 1,
      state: ActivityState.Normal,
      isChoiceBoard: false,
      order: 0,
      pictogram: mockPictogram);

  final WeekModel mockWeek = WeekModel(
      thumbnail: mockPictogram,
      name: 'TestWeek',
      weekYear: 1999,
      weekNumber: 42,
      days: <WeekdayModel>[
        WeekdayModel(day: Weekday.Sunday, activities: <ActivityModel>[])
      ]);

  setUp(() {
    httpMock = HttpMock();
    activityApi = ActivityApi(httpMock);
  });

  test('Should update an activity state', () {
    activityApi
        .update(mockActivity, mockUser.id)
        .listen(expectAsync1((ActivityModel response) {
      expect(response.toJson(), mockActivity.toJson());
    }));

    httpMock
        .expectOne(url: '/${mockUser.id}/update', method: Method.patch)
        .flush(<String, dynamic>{
      'data': mockActivity.toJson(),
      'success': true,
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should add an activity', () {
    activityApi
        .add(mockActivity, mockUser.id, mockWeek.name, mockWeek.weekYear,
            mockWeek.weekNumber, mockWeek.days.first.day)
        .listen(expectAsync1((ActivityModel response) {
      expect(response.toJson(), mockActivity.toJson());
    }));

    httpMock
        .expectOne(
            url: '/${mockUser.id}/${mockWeek.name}/${mockWeek.weekYear}/'
                '${mockWeek.weekNumber}/${mockWeek.days.first.day.index + 1}',
            method: Method.post)
        .flush(<String, dynamic>{
      'data': mockActivity.toJson(),
      'success': true,
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should delete an activity', () {
    activityApi
        .delete(mockActivity.id, mockUser.id)
        .listen(expectAsync1((bool response) {
      expect(response, true);
    }));

    httpMock
        .expectOne(
            url: '/${mockUser.id}/delete/${mockActivity.id}',
            method: Method.delete)
        .flush(<String, dynamic>{
      'success': true,
      'message': '',
      'errorKey': 'NoError',
    });
  });
}
