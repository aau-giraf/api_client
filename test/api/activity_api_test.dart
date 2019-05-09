import 'package:api_client/api/activity_api.dart';
import 'package:api_client/models/activity_model.dart';
import 'package:api_client/models/enums/access_level_enum.dart';
import 'package:api_client/models/enums/activity_state_enum.dart';
import 'package:api_client/models/pictogram_model.dart';
import 'package:api_client/models/username_model.dart';
import 'package:test_api/test_api.dart';
import 'package:api_client/http/http_mock.dart';

void main() {
  HttpMock httpMock;
  ActivityApi activityApi;
  final UsernameModel mockUser =
      UsernameModel(id: '1', name: 'Test', role: 'Guardian');

  final ActivityModel mockActivity = ActivityModel(
      id: 1,
      state: ActivityState.Normal,
      isChoiceBoard: false,
      order: 0,
      pictogram: PictogramModel(
          id: 69,
          title: 'hi',
          accessLevel: AccessLevel.PUBLIC,
          lastEdit: DateTime.now(),
          imageHash: null,
          imageUrl: null));

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
      'errorProperties': <dynamic>[],
      'errorKey': 'NoError',
    });
  });
}
