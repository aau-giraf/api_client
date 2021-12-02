import 'dart:convert';
import 'package:api_client/api/api_exception.dart';
import 'package:api_client/api/connectivity_api.dart';
import 'package:api_client/api/status_api.dart';
import 'package:api_client/http/http.dart';
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
import 'package:api_client/models/displayname_model.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
class ConnectivityMock implements Connectivity {
  bool isConnected = true;

  @override
  Future<ConnectivityResult> checkConnectivity() async {
    if (!isConnected) {
      return ConnectivityResult.none;
    }
    return ConnectivityResult.wifi;
  }

  @override
  Stream<ConnectivityResult> get onConnectivityChanged =>
      throw UnimplementedError();
}

Future<void> main() async {
  ConnectivityMock connectivityMock;
  sqfliteFfiInit();
  UserApi userApi;
  HttpMock httpMock;

  final GirafUserModel user = GirafUserModel(
      id: '1234',
      department: 3,
      role: Role.Guardian,
      roleName: 'Guardian',
      displayName: 'Kurt',
      username: 'SpaceLord69');

  final List<DisplayNameModel> usernames = <DisplayNameModel>[
    DisplayNameModel(
        displayName: 'Kurt', role: Role.SuperUser.toString(), id: '1'),
    DisplayNameModel(
        displayName: 'Hüttel', role: Role.SuperUser.toString(), id: '2'),
  ];

  final SettingsModel settings = SettingsModel(
      orientation: Orientation.Landscape,
      completeMark: CompleteMark.Checkmark,
      cancelMark: CancelMark.Cross,
      defaultTimer: DefaultTimer.PieChart,
      theme: GirafTheme.AndroidBlue,
      weekDayColors: <WeekdayColorModel>[
        WeekdayColorModel(day: Weekday.Monday, hexColor: '#123456')
      ]);
  setUp(() {
    httpMock = HttpMock();
    connectivityMock = ConnectivityMock();
    userApi = UserApi(httpMock, ConnectivityApi
                .withConnectivity(StatusApi(httpMock), connectivityMock));
  });

  test('Should fetch authenticated user', () async {
    userApi.me().listen(expectAsync1((GirafUserModel authUser) {
      expect(authUser.toJson(), user.toJson());
    }));
    await Future<dynamic>.delayed(const Duration(seconds: 1));
    httpMock.expectOne(url: '/', method: Method.get).flush(<String, dynamic>{
      'data': user.toJson(),
      'message': '',
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
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should get the role endpoint', () {
    userApi.role(user.username).listen(expectAsync1((int roleIndex) {
      expect(roleIndex, user.role.index);
    }));

    httpMock
        .expectOne(url: '/${user.username}/role', method: Method.get)
        .flush(<String, dynamic>{
      'data': user.role.index,
      'message': '',
      'errorKey': 'NoError'
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
      'message': '',
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
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should get an error when getting settings from user with ID', () {
    userApi.getSettings(user.id).listen((_) {},
        onError: expectAsync1((ApiException error) {
      expect(error.errorKey, ErrorKey.RoleMustBeCitizien);
    }));

    final Map<String, dynamic> body = <String, dynamic>{
      'data': null,
      'message': '',
      'errorKey': 'RoleMustBeCitizien',
    };

    httpMock
        .expectOne(
            url: '/${user.id}/settings', method: Method.get, statusCode: 400)
        .flush(Response(http.Response(jsonEncode(body), 400), body));
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
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should get an error when updating settings from user with ID', () {
    userApi.updateSettings(user.id, settings).listen((_) {},
        onError: expectAsync1((ApiException error) {
      expect(error.errorKey, ErrorKey.RoleMustBeCitizien);
    }));

    final Map<String, dynamic> body = <String, dynamic>{
      'message': 'hello',
      'errorKey': 'RoleMustBeCitizien',
    };

    httpMock
        .expectOne(
            url: '/${user.id}/settings', method: Method.put, statusCode: 400)
        .flush(Response(http.Response(jsonEncode(body), 400), body));
  });

  test('Should get citizens from user with ID', () {
    userApi
        .getCitizens(user.id)
        .listen(expectAsync1((List<DisplayNameModel> names) {
      expect(names.map((DisplayNameModel name) => name.toJson()),
          usernames.map((DisplayNameModel name) => name.toJson()));
    }));

    httpMock
        .expectOne(url: '/${user.id}/citizens', method: Method.get)
        .flush(<String, dynamic>{
      'data': usernames.map((DisplayNameModel name) => name.toJson()).toList(),
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should get citizens from user with ID', () {
    userApi
        .getGuardians(user.id)
        .listen(expectAsync1((List<DisplayNameModel> names) {
      expect(names.map((DisplayNameModel name) => name.toJson()),
          usernames.map((DisplayNameModel name) => name.toJson()));
    }));

    httpMock
        .expectOne(url: '/${user.id}/guardians', method: Method.get)
        .flush(<String, dynamic>{
      'data': usernames.map((DisplayNameModel name) => name.toJson()).toList(),
      'message': '',
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
      'message': '',
      'errorKey': 'NoError',
    });
  });

  tearDown(() {
    httpMock.verify();
  });
}
