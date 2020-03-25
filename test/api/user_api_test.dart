import 'package:api_client/api/api_exception.dart';
import 'package:api_client/models/enums/cancel_mark_enum.dart';
import 'package:api_client/models/enums/complete_mark_enum.dart';
import 'package:api_client/models/enums/default_timer_enum.dart';
import 'package:api_client/models/enums/error_key.dart';
import 'package:api_client/models/enums/orientation_enum.dart';
import 'package:api_client/models/enums/role_enum.dart';
import 'package:api_client/models/enums/giraf_theme_enum.dart';
import 'package:api_client/models/weekday_color_model.dart';
import 'package:api_client/models/enums/weekday_enum.dart';
import 'package:api_client/api/user_api.dart';
import 'package:api_client/http/http_mock.dart';
import 'package:api_client/models/giraf_user_model.dart';
import 'package:api_client/models/settings_model.dart';
import 'package:api_client/models/username_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  UserApi userApi;
  HttpMock httpMock;

  final GirafUserModel user = GirafUserModel(
      id: '1234',
      department: 3,
      role: Role.Guardian,
      roleName: 'Guardian',
      screenName: 'Kurt',
      username: 'SpaceLord69');

  final List<UsernameModel> usernames = <UsernameModel>[
    UsernameModel(name: 'Kurt', role: Role.SuperUser.toString(), id: '1'),
    UsernameModel(name: 'Hüttel', role: Role.SuperUser.toString(), id: '2'),
  ];

  final SettingsModel settings = SettingsModel(
      orientation: Orientation.Landscape,
      completeMark: CompleteMark.Checkmark,
      cancelMark: CancelMark.Cross,
      defaultTimer: DefaultTimer.AnalogClock,
      theme: GirafTheme.AndroidBlue,
      weekDayColors: <WeekdayColorModel>[
        WeekdayColorModel(day: Weekday.Monday, hexColor: '#123456')
      ]);

  setUp(() {
    httpMock = HttpMock();
    userApi = UserApi(httpMock);
  });

  test('Should fetch authenticated user', () {
    userApi.me().listen(expectAsync1((GirafUserModel authUser) {
      expect(authUser.toJson(), user.toJson());
    }));

    httpMock.expectOne(url: '/', method: Method.get).flush(<String, dynamic>{
      'data': user.toJson(),
      'success': true,
      'errorProperties': <dynamic>[],
      'errorKey': 'NoError',
    });
  });

  test('Should fetch user with ID', () {
    userApi.get(user.id).listen(expectAsync1((GirafUserModel specUser) {
      expect(specUser.toJson(), user.toJson());
    }));

    httpMock
        .expectOne(url: '/${user.id}', method: Method.get)
        .flush(<String, dynamic>{
      'data': user.toJson(),
      'success': true,
      'errorProperties': <dynamic>[],
      'errorKey': 'NoError',
    });
  });

  test('Should update user with ID', () {
    userApi.update(user).listen(expectAsync1((GirafUserModel specUser) {
      expect(specUser.toJson(), user.toJson());
    }));

    httpMock
        .expectOne(url: '/${user.id}', method: Method.put)
        .flush(<String, dynamic>{
      'data': user.toJson(),
      'success': true,
      'errorProperties': <dynamic>[],
      'errorKey': 'NoError',
    });
  });

  test('Should get settings from user with ID', () {
    userApi
        .getSettings(user.id)
        .listen(expectAsync1((SettingsModel specSettings) {
      expect(specSettings.toJson(), settings.toJson());
    }));

    httpMock
        .expectOne(url: '/${user.id}/settings', method: Method.get)
        .flush(<String, dynamic>{
      'data': settings.toJson(),
      'success': true,
      'errorProperties': <dynamic>[],
      'errorKey': 'NoError',
    });
  });

  test('Should get an error when getting settings from user with ID', () {
    userApi
        .getSettings(user.id)
        .listen((_) {}, onError: expectAsync1((ApiException error) {
          expect(error.errorKey, ErrorKey.RoleMustBeCitizien);
        }));

    httpMock
        .expectOne(url: '/${user.id}/settings', method: Method.get)
        .flush(<String, dynamic>{
      'data': null,
      'success': false,
      'errorProperties': <dynamic>[],
      'errorKey': 'RoleMustBeCitizien',
    });
  });

  test('Should update settings from user with ID', () {
    userApi
        .updateSettings(user.id, settings)
        .listen(expectAsync1((SettingsModel specSettings) {
      expect(specSettings.toJson(), settings.toJson());
    }));

    httpMock
        .expectOne(url: '/${user.id}/settings', method: Method.put)
        .flush(<String, dynamic>{
      'data': settings.toJson(),
      'success': true,
      'errorProperties': <dynamic>[],
      'errorKey': 'NoError',
    });
  });

  test('Should get an error when updating settings from user with ID', () {
    userApi
        .updateSettings(user.id, settings)
        .listen((_) {}, onError: expectAsync1((ApiException error) {
      expect(error.errorKey, ErrorKey.RoleMustBeCitizien);
    }));

    httpMock
        .expectOne(url: '/${user.id}/settings', method: Method.put)
        .flush(<String, dynamic>{
      'data': null,
      'success': false,
      'errorProperties': <dynamic>[],
      'errorKey': 'RoleMustBeCitizien',
    });
  });

  test('Should get citizens from user with ID', () {
    userApi
        .getCitizens(user.id)
        .listen(expectAsync1((List<UsernameModel> names) {
      expect(names.map((UsernameModel name) => name.toJson()),
          usernames.map((UsernameModel name) => name.toJson()));
    }));

    httpMock
        .expectOne(url: '/${user.id}/citizens', method: Method.get)
        .flush(<String, dynamic>{
      'data': usernames.map((UsernameModel name) => name.toJson()).toList(),
      'success': true,
      'errorProperties': <dynamic>[],
      'errorKey': 'NoError',
    });
  });

  test('Should get citizens from user with ID', () {
    userApi
        .getGuardians(user.id)
        .listen(expectAsync1((List<UsernameModel> names) {
      expect(names.map((UsernameModel name) => name.toJson()),
          usernames.map((UsernameModel name) => name.toJson()));
    }));

    httpMock
        .expectOne(url: '/${user.id}/guardians', method: Method.get)
        .flush(<String, dynamic>{
      'data': usernames.map((UsernameModel name) => name.toJson()).toList(),
      'success': true,
      'errorProperties': <dynamic>[],
      'errorKey': 'NoError',
    });
  });

  test('Should get citizens from user with ID', () {
    const String citizenId = '1234';

    userApi
        .addCitizenToGuardian(user.id, citizenId)
        .listen(expectAsync1((bool success) {
      expect(success, isTrue);
    }));

    httpMock
        .expectOne(url: '/${user.id}/citizens/$citizenId', method: Method.post)
        .flush(<String, dynamic>{
      'success': true,
      'errorProperties': <dynamic>[],
      'errorKey': 'NoError',
    });
  });

  tearDown(() {
    httpMock.verify();
  });
}
