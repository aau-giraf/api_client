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

import '../database/OfflineDatabase_test.dart';

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
  MockOfflineDbHandler dbHandlerMock;
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
    dbHandlerMock = MockOfflineDbHandler.instance;
    userApi = UserApi.withMockDbHandler(
      httpMock,
      ConnectivityApi.withConnectivity(StatusApi(httpMock), connectivityMock),
      dbHandlerMock
    );
  });

  test('Should fetch authenticated user from online', () async {
    userApi.me().listen(expectAsync1((GirafUserModel authUser) {
      expect(authUser.toJson(), user.toJson());
    }));

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    // This is expecting a call to the status api (on status())
    httpMock.expectOne(url: '/', method: Method.get).flush(<String, dynamic>{
      'data': true,
      'success': true,
      'message': '',
      'errorKey': 'NoError'
    });

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    // This is expecting a call to the user api (on me())
    httpMock.expectOne(url: '/', method: Method.get).flush(<String, dynamic>{
      'data': user.toJson(),
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should fetch authenticated user from offline', () {
    connectivityMock.isConnected = false;

    dbHandlerMock.setMe(user);

    userApi.me().listen(expectAsync1((GirafUserModel authUser) {
      expect(authUser.toJson(), user.toJson());
    }));
  });

  test('Should fetch user with ID', () async {
    userApi.get(user.id).listen(expectAsync1((GirafUserModel specUser) {
      expect(specUser.toJson(), user.toJson());
    }));

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    // This is expecting a call to the status api (on status())
    httpMock.expectOne(url: '/', method: Method.get).flush(<String, dynamic>{
    'data': true,
    'success': true,
    'message': '',
    'errorKey': 'NoError'
    });

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    httpMock.expectOne(url: '/${user.id}', method: Method.get)
        .flush(<String, dynamic>{
      'data': user.toJson(),
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should get the role endpoint', () async {
    userApi.role(user.username).listen(expectAsync1((int roleIndex) {
      expect(roleIndex, user.role.index);
    }));

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    // This is expecting a call to the status api (on status())
    httpMock.expectOne(url: '/', method: Method.get).flush(<String, dynamic>{
    'data': true,
    'success': true,
    'message': '',
    'errorKey': 'NoError'
    });

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    httpMock
        .expectOne(url: '/${user.username}/role', method: Method.get)
        .flush(<String, dynamic>{
      'data': user.role.index,
      'message': '',
      'errorKey': 'NoError'
    });
  });

  test('Should update user with ID', () async {
    userApi.update(user).listen(expectAsync1((GirafUserModel specUser) {
      expect(specUser.toJson(), user.toJson());
    }));

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    // This is expecting a call to the status api (on status())
    httpMock.expectOne(url: '/', method: Method.get).flush(<String, dynamic>{
    'data': true,
    'success': true,
    'message': '',
    'errorKey': 'NoError'
    });

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    httpMock
        .expectOne(url: '/${user.id}', method: Method.put)
        .flush(<String, dynamic>{
      'data': user.toJson(),
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should get settings from user with ID', () async {
    userApi
        .getSettings(user.id)
        .listen(expectAsync1((SettingsModel specSettings) {
      expect(specSettings.toJson(), settings.toJson());
    }));

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    // This is expecting a call to the status api (on status())
    httpMock.expectOne(url: '/', method: Method.get).flush(<String, dynamic>{
    'data': true,
    'success': true,
    'message': '',
    'errorKey': 'NoError'
    });

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    httpMock
        .expectOne(url: '/${user.id}/settings', method: Method.get)
        .flush(<String, dynamic>{
      'data': settings.toJson(),
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should get an error when getting settings from user with ID', () async {
    userApi.getSettings(user.id).listen((_) {},
        onError: expectAsync1((ApiException error) {
      expect(error.errorKey, ErrorKey.RoleMustBeCitizien);
    }));

    final Map<String, dynamic> body = <String, dynamic>{
      'data': null,
      'message': '',
      'errorKey': 'RoleMustBeCitizien',
    };

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    // This is expecting a call to the status api (on status())
    httpMock.expectOne(url: '/', method: Method.get).flush(<String, dynamic>{
    'data': true,
    'success': true,
    'message': '',
    'errorKey': 'NoError'
    });

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    httpMock
        .expectOne(
            url: '/${user.id}/settings', method: Method.get, statusCode: 400)
        .flush(Response(http.Response(jsonEncode(body), 400), body));
  });

  test('Should update settings from user with ID', () async {
    userApi
        .updateSettings(user.id, settings)
        .listen(expectAsync1((SettingsModel specSettings) {
      expect(specSettings.toJson(), settings.toJson());
    }));

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    // This is expecting a call to the status api (on status())
    httpMock.expectOne(url: '/', method: Method.get).flush(<String, dynamic>{
    'data': true,
    'success': true,
    'message': '',
    'errorKey': 'NoError'
    });

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    httpMock
        .expectOne(url: '/${user.id}/settings', method: Method.put)
        .flush(<String, dynamic>{
      'data': settings.toJson(),
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should get an error when updating settings from user with ID', ()async {
    userApi.updateSettings(user.id, settings).listen((_) {},
        onError: expectAsync1((ApiException error) {
      expect(error.errorKey, ErrorKey.RoleMustBeCitizien);
    }));

    final Map<String, dynamic> body = <String, dynamic>{
      'message': 'hello',
      'errorKey': 'RoleMustBeCitizien',
    };

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    // This is expecting a call to the status api (on status())
    httpMock.expectOne(url: '/', method: Method.get).flush(<String, dynamic>{
      'data': true,
      'success': true,
      'message': '',
      'errorKey': 'NoError'
    });

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    httpMock
        .expectOne(
            url: '/${user.id}/settings', method: Method.put, statusCode: 400)
        .flush(Response(http.Response(jsonEncode(body), 400), body));
  });

  test('Should get citizens from user with ID', () async {
    userApi
        .getCitizens(user.id)
        .listen(expectAsync1((List<DisplayNameModel> names) {
      expect(names.map((DisplayNameModel name) => name.toJson()),
          usernames.map((DisplayNameModel name) => name.toJson()));
    }));

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    // This is expecting a call to the status api (on status())
    httpMock.expectOne(url: '/', method: Method.get).flush(<String, dynamic>{
      'data': true,
      'success': true,
      'message': '',
      'errorKey': 'NoError'
    });

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    httpMock
        .expectOne(url: '/${user.id}/citizens', method: Method.get)
        .flush(<String, dynamic>{
      'data': usernames.map((DisplayNameModel name) => name.toJson()).toList(),
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should get citizens from user with ID', () async {
    userApi
        .getGuardians(user.id)
        .listen(expectAsync1((List<DisplayNameModel> names) {
      expect(names.map((DisplayNameModel name) => name.toJson()),
          usernames.map((DisplayNameModel name) => name.toJson()));
    }));

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    // This is expecting a call to the status api (on status())
    httpMock.expectOne(url: '/', method: Method.get).flush(<String, dynamic>{
      'data': true,
      'success': true,
      'message': '',
      'errorKey': 'NoError'
    });

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    httpMock
        .expectOne(url: '/${user.id}/guardians', method: Method.get)
        .flush(<String, dynamic>{
      'data': usernames.map((DisplayNameModel name) => name.toJson()).toList(),
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should get citizens from user with ID', () async {
    const String citizenId = '1234';

    userApi.addCitizenToGuardian(user.id, citizenId)
        .listen(expectAsync1((bool success) {
      expect(success, isTrue);
    }));

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    // This is expecting a call to the status api (on status())
    httpMock.expectOne(url: '/', method: Method.get).flush(<String, dynamic>{
      'data': true,
      'success': true,
      'message': '',
      'errorKey': 'NoError'
    });

    await Future<dynamic>.delayed(const Duration(seconds: 1));

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
