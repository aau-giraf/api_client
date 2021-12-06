import 'dart:convert';
import 'dart:typed_data';
import 'package:api_client/api/api_exception.dart';
import 'package:api_client/api/connectivity_api.dart';
import 'package:api_client/api/status_api.dart';
import 'package:api_client/http/http.dart';
import 'package:api_client/models/activity_model.dart';
import 'package:api_client/models/enums/cancel_mark_enum.dart';
import 'package:api_client/models/enums/complete_mark_enum.dart';
import 'package:api_client/models/enums/default_timer_enum.dart';
import 'package:api_client/models/enums/error_key.dart';
import 'package:api_client/models/enums/orientation_enum.dart';
import 'package:api_client/models/enums/role_enum.dart';
import 'package:api_client/models/enums/giraf_theme_enum.dart';
import 'package:api_client/models/pictogram_model.dart';
import 'package:api_client/models/timer_model.dart';
import 'package:api_client/models/week_model.dart';
import 'package:api_client/models/week_name_model.dart';
import 'package:api_client/models/week_template_model.dart';
import 'package:api_client/models/week_template_name_model.dart';
import 'package:api_client/models/weekday_color_model.dart';
import 'package:api_client/models/enums/weekday_enum.dart';
import 'package:api_client/api/user_api.dart';
import 'package:api_client/http/http_mock.dart';
import 'package:api_client/models/giraf_user_model.dart';
import 'package:api_client/models/settings_model.dart';
import 'package:api_client/models/displayname_model.dart';
import 'package:api_client/offline_database/offline_db_handler.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/src/widgets/image.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite_common/sqlite_api.dart';
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

class DBHandlerMock implements OfflineDbHandler {
  GirafUserModel _authUser;

  @override
  Future<ActivityModel> addActivity(ActivityModel activity, String userId, String weekplanName, int weekYear, int weekNumber, Weekday weekDay, {TimerModel timer}) {
    // TODO: implement addActivity
    throw UnimplementedError();
  }

  @override
  Future<bool> addCitizenToGuardian(String guardianId, String citizenId) {
    return Future<bool>.value(true);
  }

  @override
  Future<bool> changePassword(String id, String newPassword) {
    // TODO: implement changePassword
    throw UnimplementedError();
  }

  @override
  Future<void> closeDb() {
    // TODO: implement closeDb
    throw UnimplementedError();
  }

  @override
  Future<PictogramModel> createPictogram(PictogramModel pictogram) {
    // TODO: implement createPictogram
    throw UnimplementedError();
  }

  @override
  Future<void> createTables(Database db) {
    // TODO: implement createTables
    throw UnimplementedError();
  }

  @override
  Future<WeekTemplateModel> createTemplate(WeekTemplateModel template) {
    // TODO: implement createTemplate
    throw UnimplementedError();
  }

  @override
  // TODO: implement database
  Future<Database> get database => throw UnimplementedError();

  @override
  Future<bool> deleteAccount(String id) {
    // TODO: implement deleteAccount
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteActivity(int activityId, String userId) {
    // TODO: implement deleteActivity
    throw UnimplementedError();
  }

  @override
  Future<bool> deletePictogram(int id) {
    // TODO: implement deletePictogram
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteTemplate(int id) {
    // TODO: implement deleteTemplate
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteUserIcon(String id) {
    // TODO: implement deleteUserIcon
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteWeek(String id, int year, int weekNumber) {
    // TODO: implement deleteWeek
    throw UnimplementedError();
  }

  @override
  Future<List<PictogramModel>> getAllPictograms({String query, int page, int pageSize}) {
    // TODO: implement getAllPictograms
    throw UnimplementedError();
  }

  @override
  Future<List<DisplayNameModel>> getCitizens(String id) {
    // TODO: implement getCitizens
    throw UnimplementedError();
  }

  @override
  Future<int> getCurrentDBVersion() {
    // TODO: implement getCurrentDBVersion
    throw UnimplementedError();
  }

  @override
  Future<List<DisplayNameModel>> getGuardians(String id) {
    // TODO: implement getGuardians
    throw UnimplementedError();
  }

  @override
  Http getHttpObject() {
    // TODO: implement getHttpObject
    throw UnimplementedError();
  }

  @override
  GirafUserModel getMe() {
    return _authUser;
  }

  @override
  // TODO: implement getPictogramDirectory
  Future<String> get getPictogramDirectory => throw UnimplementedError();

  @override
  Future<PictogramModel> getPictogramID(int id) {
    // TODO: implement getPictogramID
    throw UnimplementedError();
  }

  @override
  Future<Image> getPictogramImage(int id) {
    // TODO: implement getPictogramImage
    throw UnimplementedError();
  }

  @override
  Future<WeekTemplateModel> getTemplate(int id) {
    // TODO: implement getTemplate
    throw UnimplementedError();
  }

  @override
  Future<List<WeekTemplateNameModel>> getTemplateNames() {
    // TODO: implement getTemplateNames
    throw UnimplementedError();
  }

  @override
  Future<GirafUserModel> getUser(String id) {
    return Future<GirafUserModel>.value(GirafUserModel(
        id: '1236',
        department: 3,
        role: Role.Guardian,
        roleName: 'Guardian',
        displayName: 'Kurt',
        username: 'SpaceLord67'));
  }

  @override
  Future<Image> getUserIcon(String id) {
    // TODO: implement getUserIcon
    throw UnimplementedError();
  }

  @override
  Future<String> getUserId(String userName) {
    return Future<String>.value('1');
  }

  @override
  Future<int> getUserRole(String username) {
    return Future<int>.value(3);
  }

  @override
  Future<SettingsModel> getUserSettings(String id) {
    return Future<SettingsModel>.value(SettingsModel(
        orientation: Orientation.Landscape,
        completeMark: CompleteMark.Checkmark,
        cancelMark: CancelMark.Cross,
        defaultTimer: DefaultTimer.PieChart,
        theme: GirafTheme.AndroidBlue,
        weekDayColors: <WeekdayColorModel>[
          WeekdayColorModel(day: Weekday.Monday, hexColor: '#123456')
        ]));
  }

  @override
  Future<WeekModel> getWeek(String id, int year, int weekNumber) {
    // TODO: implement getWeek
    throw UnimplementedError();
  }

  @override
  Future<List<WeekNameModel>> getWeekNames(String id) {
    // TODO: implement getWeekNames
    throw UnimplementedError();
  }

  @override
  Future<Database> initializeDatabase() {
    // TODO: implement initializeDatabase
    throw UnimplementedError();
  }

  @override
  Future<GirafUserModel> insertUser(GirafUserModel user) {
    // TODO: implement insertUser
    throw UnimplementedError();
  }

  @override
  Future<Image> insertUserIcon(String id, Image icon) {
    // TODO: implement insertUserIcon
    throw UnimplementedError();
  }

  @override
  Future<SettingsModel> insertUserSettings(String userId, SettingsModel settings) {
    return Future<SettingsModel>.value(settings);
  }

  @override
  Future<bool> login(String username, String password) {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future<GirafUserModel> registerAccount(Map<String, dynamic> body) {
    // TODO: implement registerAccount
    throw UnimplementedError();
  }

  @override
  Future<void> removeFailedTransaction(Map<String, dynamic> transaction) {
    // TODO: implement removeFailedTransaction
    throw UnimplementedError();
  }

  @override
  Future<void> replaceTempIdPictogram(int oldId, int newId) {
    // TODO: implement replaceTempIdPictogram
    throw UnimplementedError();
  }

  @override
  Future<void> replaceTempIdUsers(int oldId, int newId) {
    // TODO: implement replaceTempIdUsers
    throw UnimplementedError();
  }

  @override
  Future<void> replaceTempIdWeekTemplate(int oldId, int newId) {
    // TODO: implement replaceTempIdWeekTemplate
    throw UnimplementedError();
  }

  @override
  Future<void> retryFailedTransactions() {
    // TODO: implement retryFailedTransactions
    throw UnimplementedError();
  }

  @override
  Future<void> saveFailedTransactions(String type, String baseUrl, String url, {Map<String, dynamic> body, String tableAffected, String tempId}) {
    // TODO: implement saveFailedTransactions
    throw UnimplementedError();
  }

  @override
  void setMe(GirafUserModel model) {
    _authUser = model;
  }

  @override
  Future<ActivityModel> updateActivity(ActivityModel activity, String userId) {
    // TODO: implement updateActivity
    throw UnimplementedError();
  }

  @override
  Future<void> updateIdInOfflineDb(Map<String, dynamic> json, String table, int tempId) {
    // TODO: implement updateIdInOfflineDb
    throw UnimplementedError();
  }

  @override
  Future<PictogramModel> updateImageInPictogram(int id, Uint8List image) {
    // TODO: implement updateImageInPictogram
    throw UnimplementedError();
  }

  @override
  Future<PictogramModel> updatePictogram(PictogramModel pictogram) {
    // TODO: implement updatePictogram
    throw UnimplementedError();
  }

  @override
  Future<WeekTemplateModel> updateTemplate(WeekTemplateModel template) {
    // TODO: implement updateTemplate
    throw UnimplementedError();
  }

  @override
  Future<GirafUserModel> updateUser(GirafUserModel user) {
    return Future<GirafUserModel>.value(user);
  }

  @override
  Future<bool> updateUserIcon() {
    // TODO: implement updateUserIcon
    throw UnimplementedError();
  }

  @override
  Future<bool> updateUserSettings(String id, SettingsModel settings) {
    return Future<bool>.value(true);
  }

  @override
  Future<WeekModel> updateWeek(String id, int year, int weekNumber, WeekModel week) {
    // TODO: implement updateWeek
    throw UnimplementedError();
  }
}

Future<void> main() async {
  ConnectivityMock connectivityMock;
  sqfliteFfiInit();
  DBHandlerMock dbHandlerMock;
  UserApi userApi;
  HttpMock httpMock;

  final GirafUserModel user = GirafUserModel(
      id: '1236',
      department: 3,
      role: Role.Guardian,
      roleName: 'Guardian',
      displayName: 'Kurt',
      username: 'SpaceLord67');

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
    dbHandlerMock = DBHandlerMock();
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
  
  test('Should fetch user with ID from offline', () {
    connectivityMock.isConnected = false;
    userApi.get(user.id).listen(expectAsync1((GirafUserModel specUser) {
      expect(specUser.toJson(), user.toJson());
    }));
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

  test('Should get the role endpoint from offline', () {
    connectivityMock.isConnected = false;
    userApi.role(user.username).listen(expectAsync1((int roleIndex) {
      expect(roleIndex, user.role.index);
    }));
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

  test('Should update user with ID from offline', () {
    connectivityMock.isConnected = false;
    userApi.update(user).listen(expectAsync1((GirafUserModel specUser) {
      expect(specUser.toJson(), user.toJson());
    }));
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

  test('Should update settings from user with ID', () async {
    userApi
        .updateSettings(user.id, settings)
        .listen(expectAsync1((bool success) {
      expect(success, true);
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

  test('Should get guardians from user with ID', () async {
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

  test('Should add citizen to guardian with ID', () async {
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
