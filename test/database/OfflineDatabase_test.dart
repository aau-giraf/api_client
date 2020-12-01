import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:api_client/api/api_exception.dart';
import 'package:api_client/http/http.dart';
import 'package:api_client/http/http_mock.dart';
import 'package:api_client/models/activity_model.dart';
import 'package:api_client/models/displayname_model.dart';
import 'package:api_client/models/enums/access_level_enum.dart';
import 'package:api_client/models/enums/cancel_mark_enum.dart';
import 'package:api_client/models/enums/complete_mark_enum.dart';
import 'package:api_client/models/enums/default_timer_enum.dart';
import 'package:api_client/models/enums/giraf_theme_enum.dart';
import 'package:api_client/models/enums/orientation_enum.dart' as orient;
import 'package:api_client/models/enums/role_enum.dart';
import 'package:api_client/models/enums/weekday_enum.dart';
import 'package:api_client/models/giraf_user_model.dart';
import 'package:api_client/models/pictogram_model.dart';
import 'package:api_client/models/settings_model.dart';
import 'package:api_client/models/timer_model.dart';
import 'package:api_client/models/week_model.dart';
import 'package:api_client/models/week_name_model.dart';
import 'package:api_client/models/week_template_model.dart';
import 'package:api_client/models/week_template_name_model.dart';
import 'package:api_client/models/weekday_model.dart';
import 'package:api_client/offline_database/offline_db_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'Offline_models.dart';

class MockOfflineDbHandler extends OfflineDbHandler {
  MockOfflineDbHandler._() : super();

  static final MockOfflineDbHandler instance = MockOfflineDbHandler._();
  @override
  Future<Database> initializeDatabase() async {
    sqfliteFfiInit();
    final String tempDir = Directory.current.path;
    String dbDir;
    Database db;
    if (tempDir.split(separator).last == 'test') {
      dbDir = join(tempDir, 'database');
    } else {
      dbDir = join(tempDir, 'test', 'database');
    }
    db = await databaseFactoryFfi.openDatabase(join(dbDir, 'girafTest.db'),
        options: OpenDatabaseOptions(version: 1));
    createTables(db);
    return db;
  }

  @override
  Future<String> get getPictogramDirectory async {
    final String tempDir = Directory.current.path;
    Directory imageDirectory;
    if (tempDir.split(separator).last == 'test') {
      imageDirectory = Directory(join(tempDir, 'pictograms'));
    } else {
      imageDirectory = Directory(join(tempDir, 'test', 'pictograms'));
    }
    imageDirectory.createSync(recursive: true);
    return imageDirectory.path;
  }

  @override
  Http getHttpObject() {
    return httpMock;
  }
}

final HttpMock httpMock = HttpMock();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  final MockOfflineDbHandler dbHandler = MockOfflineDbHandler.instance;
  tearDown(() async {
    await killAll(dbHandler);
  });

  test('Try to create the test db', () async {
    expect(await dbHandler.getCurrentDBVersion(), 1);
    // We might need this if somthing is wrong
    // in the tests and it doesn't close itself
    //dbHandler.closeDb();
  });
  test('update an activity without timer to one that has timer', () async {
    final PictogramModel testPicto = await dbHandler.createPictogram(scrum);
    final File pictoImage = await addImageToPictoGram(testPicto, dbHandler);
    final GirafUserModel jamesUser = await dbHandler.registerAccount(jamesBody);
    final WeekModel userWeek = await dbHandler.updateWeek(jamesUser.id,
        blankTestWeek.weekYear, blankTestWeek.weekNumber, blankTestWeek);

    expect(userWeek.days[0].day, blankTestWeek.days[0].day);
    expect(userWeek.thumbnail.id, blankTestWeek.thumbnail.id);
    final ActivityModel testActivity = await dbHandler.addActivity(
        spise,
        jamesUser.id,
        blankTestWeek.name,
        blankTestWeek.weekYear,
        blankTestWeek.weekNumber,
        Weekday.Friday);
    final TimerModel timer = TimerModel(
        startTime: DateTime(1, 1, 1, 1),
        progress: 0,
        fullLength: 0,
        paused: false);
    final ActivityModel testActivityTimer = ActivityModel(
        id: testActivity.id,
        pictograms: testActivity.pictograms,
        order: testActivity.order,
        state: testActivity.state,
        isChoiceBoard: testActivity.isChoiceBoard,
        timer: timer);
    blankTestWeek.days[0].activities = <ActivityModel>[testActivity];
    final ActivityModel updatedActivity =
        await dbHandler.updateActivity(testActivityTimer, jamesUser.id);
    expect(updatedActivity.timer.progress, 0);
    await pictoImage.delete();
  });

  test('Test if getweeknames gets all weeks connected to user', () async {
    final PictogramModel testPicto = await dbHandler.createPictogram(scrum);
    final File pictoImage = await addImageToPictoGram(testPicto, dbHandler);
    final GirafUserModel jamesUser = await dbHandler.registerAccount(jamesBody);
    await dbHandler.updateWeek(jamesUser.id, blankTestWeek.weekYear,
        blankTestWeek.weekNumber, blankTestWeek);
    await dbHandler.updateWeek(jamesUser.id, testWeekModel.weekYear,
        testWeekModel.weekNumber, testWeekModel);
    final List<WeekNameModel> res = await dbHandler.getWeekNames(jamesUser.id);
    expect(res.length == 2, true);
    await pictoImage.delete();
  });

  test('Register an account in the offline db', () async {
    //create fake account

    final GirafUserModel fakeUserRes =
        await dbHandler.registerAccount(jamesBody);
    expect(fakeUserRes.username, jamesbondTestUser.username);
    expect(fakeUserRes.displayName, jamesbondTestUser.displayName);
    expect(fakeUserRes.role, Role.Citizen);
    await cleanUsers(dbHandler);
  });

  test('Register an account in the offline db', () async {
    //create fake account
    final GirafUserModel fakeUserRes =
        await dbHandler.registerAccount(jamesBodySuper);
    expect(fakeUserRes.username, jamesbondSuperUser.username);
    expect(fakeUserRes.displayName, jamesbondSuperUser.displayName);
    expect(fakeUserRes.role, Role.SuperUser);
    await cleanUsers(dbHandler);
  });

  test('Save data in the table for failed transactions', () async {
    const String testTransType = 'PUT';
    const String testBaseUrl = 'http://10.0.2.2:5000';
    const String testUrl = '/register';
    const String testTable = 'Users';
    const String testId = '1';
    dbHandler.saveFailedTransactions(testTransType, testBaseUrl, testUrl,
        body: jamesBody, tableAffected: testTable, tempId: testId);
    final Database db = await dbHandler.database;
    final List<Map<String, dynamic>> dbRes =
        await db.rawQuery('SELECT * FROM `FailedOnlineTransactions` '
            "WHERE TempId == '$testId'");
    expect(dbRes[0]['TempId'], testId);
    expect(dbRes[0]['Body'], jamesBody.toString());
  });

  test('Retry failed put transaction', () async {
    const String testTransType = 'PUT';
    const String testBaseUrl = 'http://10.0.2.2:5000';
    const String testUrl = '/register';
    const String testTable = 'Users';
    const String testId = '1';
    await dbHandler.saveFailedTransactions(testTransType, testBaseUrl, testUrl,
        body: jamesBody, tableAffected: testTable, tempId: testId);
    await dbHandler.retryFailedTransactions();

    httpMock
        .expectOne(url: 'http://10.0.2.2:5000/register', method: Method.put)
        .flush(<String, dynamic>{
      'data': <String, dynamic>{
        'role': jamesBody['role'],
        'roleName': 'Citizen',
        'id': '1',
        'username': jamesBody['username'],
        'displayName': jamesBody['displayname'],
        'department': jamesBody['department'],
      },
      'message': '',
      'errorKey': 'NoError',
    });

    List<Map<String, dynamic>> res;
    await Future<void>.delayed(const Duration(milliseconds: 10))
        .then((_) async {
      res = await (await dbHandler.database)
          .rawQuery('SELECT * FROM `FailedOnlineTransactions` '
              "WHERE TempId == '$testId'");
    });
    expect(res.isEmpty, true);
  });

  test('Retry failed put transaction, failed', () async {
    const String testTransType = 'PUT';
    const String testBaseUrl = 'http://10.0.2.2:5000';
    const String testUrl = '/register';
    const String testTable = 'Users';
    const String testId = '1';
    await dbHandler.saveFailedTransactions(testTransType, testBaseUrl, testUrl,
        body: jamesBody, tableAffected: testTable, tempId: testId);
    await dbHandler.retryFailedTransactions();

    httpMock
        .expectOne(url: 'http://10.0.2.2:5000/register', method: Method.put)
        .throwError(ApiException(Response(null, <String, dynamic>{
          'success': false,
          'message': '',
          'errorKey': 'InvalidCredentials',
        })));

    List<Map<String, dynamic>> res;
    await Future<void>.delayed(const Duration(milliseconds: 10))
        .then((_) async {
      res = await (await dbHandler.database)
          .rawQuery('SELECT * FROM `FailedOnlineTransactions` '
              "WHERE TempId == '$testId'");
    });
    expect(res.isEmpty, false);
  });

  test('Retry failed delete transaction', () async {
    const String testTransType = 'DELETE';
    const String testBaseUrl = 'http://10.0.2.2:5000';
    const String testUrl = '/register';
    const String testTable = 'Users';
    const String testId = '1';
    await dbHandler.saveFailedTransactions(testTransType, testBaseUrl, testUrl,
        body: jamesBody, tableAffected: testTable, tempId: testId);
    await dbHandler.retryFailedTransactions();

    httpMock
        .expectOne(url: 'http://10.0.2.2:5000/register', method: Method.delete)
        .flush(<String, dynamic>{
      'data': <String, dynamic>{
        'role': jamesBody['role'],
        'roleName': 'Citizen',
        'id': '1',
        'username': jamesBody['username'],
        'displayName': jamesBody['displayname'],
        'department': jamesBody['department'],
      },
      'message': '',
      'errorKey': 'NoError',
    });

    List<Map<String, dynamic>> res;
    await Future<void>.delayed(const Duration(milliseconds: 10))
        .then((_) async {
      res = await (await dbHandler.database)
          .rawQuery('SELECT * FROM `FailedOnlineTransactions` '
              "WHERE TempId == '$testId'");
    });
    expect(res.isEmpty, true);
  });

  test('Retry failed delete transaction, failed', () async {
    const String testTransType = 'DELETE';
    const String testBaseUrl = 'http://10.0.2.2:5000';
    const String testUrl = '/register';
    const String testTable = 'Users';
    const String testId = '1';
    await dbHandler.saveFailedTransactions(testTransType, testBaseUrl, testUrl,
        body: jamesBody, tableAffected: testTable, tempId: testId);
    await dbHandler.retryFailedTransactions();

    httpMock
        .expectOne(url: 'http://10.0.2.2:5000/register', method: Method.delete)
        .throwError(ApiException(Response(null, <String, dynamic>{
          'success': false,
          'message': '',
          'errorKey': 'InvalidCredentials',
        })));

    List<Map<String, dynamic>> res;
    await Future<void>.delayed(const Duration(milliseconds: 10))
        .then((_) async {
      res = await (await dbHandler.database)
          .rawQuery('SELECT * FROM `FailedOnlineTransactions` '
              "WHERE TempId == '$testId'");
    });
    expect(res.isEmpty, false);
  });

  test('Retry failed post transaction', () async {
    const String testTransType = 'POST';
    const String testBaseUrl = 'http://10.0.2.2:5000';
    const String testUrl = '/register';
    const String testTable = 'Users';
    const String testId = '1';
    await dbHandler.saveFailedTransactions(testTransType, testBaseUrl, testUrl,
        body: jamesBody, tableAffected: testTable, tempId: testId);
    await dbHandler.retryFailedTransactions();

    httpMock
        .expectOne(url: 'http://10.0.2.2:5000/register', method: Method.post)
        .flush(<String, dynamic>{
      'data': <String, dynamic>{
        'role': jamesBody['role'],
        'roleName': 'Citizen',
        'id': '1',
        'username': jamesBody['username'],
        'displayName': jamesBody['displayname'],
        'department': jamesBody['department'],
      },
      'message': '',
      'errorKey': 'NoError',
    });

    List<Map<String, dynamic>> res;
    await Future<void>.delayed(const Duration(milliseconds: 10))
        .then((_) async {
      res = await (await dbHandler.database)
          .rawQuery('SELECT * FROM `FailedOnlineTransactions` '
              "WHERE TempId == '$testId'");
    });
    expect(res.isEmpty, true);
  });

  test('Retry failed post transaction, failed', () async {
    const String testTransType = 'POST';
    const String testBaseUrl = 'http://10.0.2.2:5000';
    const String testUrl = '/register';
    const String testTable = 'Users';
    const String testId = '1';
    await dbHandler.saveFailedTransactions(testTransType, testBaseUrl, testUrl,
        body: jamesBody, tableAffected: testTable, tempId: testId);
    await dbHandler.retryFailedTransactions();

    httpMock
        .expectOne(url: 'http://10.0.2.2:5000/register', method: Method.post)
        .throwError(ApiException(Response(null, <String, dynamic>{
          'success': false,
          'message': '',
          'errorKey': 'InvalidCredentials',
        })));

    List<Map<String, dynamic>> res;
    await Future<void>.delayed(const Duration(milliseconds: 10))
        .then((_) async {
      res = await (await dbHandler.database)
          .rawQuery('SELECT * FROM `FailedOnlineTransactions` '
              "WHERE TempId == '$testId'");
    });
    expect(res.isEmpty, false);
  });

  test('Retry failed patch transaction', () async {
    const String testTransType = 'PATCH';
    const String testBaseUrl = 'http://10.0.2.2:5000';
    const String testUrl = '/register';
    const String testTable = 'Users';
    const String testId = '1';
    await dbHandler.saveFailedTransactions(testTransType, testBaseUrl, testUrl,
        body: jamesBody, tableAffected: testTable, tempId: testId);
    await dbHandler.retryFailedTransactions();

    httpMock
        .expectOne(url: 'http://10.0.2.2:5000/register', method: Method.patch)
        .flush(<String, dynamic>{
      'data': <String, dynamic>{
        'role': jamesBody['role'],
        'roleName': 'Citizen',
        'id': '1',
        'username': jamesBody['username'],
        'displayName': jamesBody['displayname'],
        'department': jamesBody['department'],
      },
      'message': '',
      'errorKey': 'NoError',
    });

    List<Map<String, dynamic>> res;
    await Future<void>.delayed(const Duration(milliseconds: 10))
        .then((_) async {
      res = await (await dbHandler.database)
          .rawQuery('SELECT * FROM `FailedOnlineTransactions` '
              "WHERE TempId == '$testId'");
    });
    expect(res.isEmpty, true);
  });

  test('Retry failed patch transaction, failed', () async {
    const String testTransType = 'PATCH';
    const String testBaseUrl = 'http://10.0.2.2:5000';
    const String testUrl = '/register';
    const String testTable = 'Users';
    const String testId = '1';
    await dbHandler.saveFailedTransactions(testTransType, testBaseUrl, testUrl,
        body: jamesBody, tableAffected: testTable, tempId: testId);
    await dbHandler.retryFailedTransactions();

    httpMock
        .expectOne(url: 'http://10.0.2.2:5000/register', method: Method.patch)
        .throwError(ApiException(Response(null, <String, dynamic>{
          'success': false,
          'message': '',
          'errorKey': 'InvalidCredentials',
        })));

    List<Map<String, dynamic>> res;
    await Future<void>.delayed(const Duration(milliseconds: 10))
        .then((_) async {
      res = await (await dbHandler.database)
          .rawQuery('SELECT * FROM `FailedOnlineTransactions` '
              "WHERE TempId == '$testId'");
    });
    expect(res.isEmpty, false);
  });

  test('Test if it is possible to register the same account twice', () async {
    //create fake account
    await dbHandler.registerAccount(jamesBody);
    expect(() => dbHandler.registerAccount(jamesBody),
        throwsA(isInstanceOf<Exception>()));
    await killAll(dbHandler);
  });

  test('Find a user ID through their username', () async {
    final GirafUserModel jamesUser = await dbHandler.registerAccount(jamesBody);

    final String idReturn = await dbHandler.getUserId(jamesUser.username);
    expect(idReturn, jamesUser.id);
  });
  test('Add activity test', () async {
    final WeekdayModel testDay =
        WeekdayModel(day: Weekday.Friday, activities: null);
    final List<WeekdayModel> testWeekDay = <WeekdayModel>[testDay];

    final WeekModel testWeek = WeekModel(
        days: testWeekDay,
        name: 'Min Uge',
        thumbnail: extreme,
        weekNumber: 28,
        weekYear: 2020);

    final PictogramModel testPicto = await dbHandler.createPictogram(extreme);
    final File pictoImage = await addImageToPictoGram(testPicto, dbHandler);
    final GirafUserModel jamesUser = await dbHandler.registerAccount(jamesBody);
    final WeekModel userWeek = await dbHandler.updateWeek(
        jamesUser.id, testWeek.weekYear, testWeek.weekNumber, testWeek);

    expect(userWeek.days[0].day, testWeek.days[0].day);
    expect(userWeek.thumbnail.id, testWeek.thumbnail.id);

    final ActivityModel testActivity = await dbHandler.addActivity(
        lege,
        jamesUser.id,
        testWeek.name,
        testWeek.weekYear,
        testWeek.weekNumber,
        Weekday.Friday);

    testWeek.days[0].activities = <ActivityModel>[testActivity];
    final WeekModel updatedWeek = await dbHandler.updateWeek(
        jamesUser.id, userWeek.weekYear, userWeek.weekNumber, userWeek);
    expect(updatedWeek.days[0].activities.isNotEmpty, true);
    await pictoImage.delete();
  });
  test('Add activity test with timer', () async {
    final WeekdayModel testDay =
        WeekdayModel(day: Weekday.Friday, activities: null);
    final List<WeekdayModel> testWeekDay = <WeekdayModel>[testDay];

    final WeekModel testWeek = WeekModel(
        days: testWeekDay,
        name: 'Min Uge',
        thumbnail: extreme,
        weekNumber: 28,
        weekYear: 2020);

    final PictogramModel testPicto = await dbHandler.createPictogram(extreme);
    final File pictoImage = await addImageToPictoGram(testPicto, dbHandler);
    final GirafUserModel jamesUser = await dbHandler.registerAccount(jamesBody);
    final WeekModel userWeek = await dbHandler.updateWeek(
        jamesUser.id, testWeek.weekYear, testWeek.weekNumber, testWeek);

    expect(userWeek.days[0].day, testWeek.days[0].day);
    expect(userWeek.thumbnail.id, testWeek.thumbnail.id);
    final ActivityModel testActivity = await dbHandler.addActivity(
        sandkasse,
        jamesUser.id,
        testWeek.name,
        testWeek.weekYear,
        testWeek.weekNumber,
        Weekday.Friday);

    testWeek.days[0].activities = <ActivityModel>[testActivity];
    final ActivityModel updatedActivity =
        await dbHandler.updateActivity(testActivity, jamesUser.id);
    expect(updatedActivity.timer.key, timer.key);
    await pictoImage.delete();
  });
  test('Perform a correct login attempt', () async {
    // The correct Password for the jamesBody user is 'TestPassword123'
    const String passAttempt = 'TestPassword123';
    await dbHandler.registerAccount(jamesBody);
    final bool testLogin =
        await dbHandler.login(jamesbondTestUser.username, passAttempt);
    expect(testLogin, true);
  });

  test('Perform a correct login attempt 2', () async {
    const String testUsername = 'JacobPed';
    const String testPassword = 'hunter2';
    final Map<String, dynamic> dbUser = <String, dynamic>{
      'username': testUsername,
      'displayName': 'Jacob Pedersen',
      'password': testPassword,
      'departmentId': 1,
      'role': 'Citizen',
    };
    await dbHandler.registerAccount(dbUser);
    final bool testLogin = await dbHandler.login(testUsername, testPassword);
    expect(testLogin, true);
  });

  test('Perform a incorrect login attempt', () async {
    // The correct Password for the jamesBody user is 'TestPassword123'
    const String passAttempt = 'GoldenGun';
    await dbHandler.registerAccount(jamesBody);
    final bool testLogin =
        await dbHandler.login(jamesbondTestUser.username, passAttempt);
    expect(testLogin, false);
  });

  test('Perform a incorrect login attempt 2', () async {
    const String testUsername = 'SErikson';
    const String testPassword = 'hejmeddig123';
    const String passAttempt = 'Hejmeddig123';
    final Map<String, dynamic> dbUser = <String, dynamic>{
      'username': testUsername,
      'displayName': 'Simon Erikson',
      'password': testPassword,
      'departmentId': 1,
      'role': 'Guardian',
    };
    await dbHandler.registerAccount(dbUser);
    final bool testLogin = await dbHandler.login(testUsername, passAttempt);
    expect(testLogin, false);
  });

  test('Update a user with a new attribute', () async {
    final GirafUserModel formerUser =
        await dbHandler.registerAccount(jamesBody);
    expect(formerUser.username, jamesbondTestUser.username);
    final GirafUserModel updatedUser = formerUser;
    updatedUser.username = 'DoubleOhSeven';
    final GirafUserModel newUser = await dbHandler.updateUser(updatedUser);
    expect(newUser.id, formerUser.id);
    expect(newUser.username, updatedUser.username);
  });
  test('Create a pictogram in the offline database', () async {
    await dbHandler.createPictogram(scrum);
    final PictogramModel dbPicto = await dbHandler.getPictogramID(scrum.id);
    expect(dbPicto.id, scrum.id);
  });

  test('Update existing pictogram in database', () async {
    await dbHandler.createPictogram(scrum);
    final PictogramModel scrum2 = PictogramModel(
      id: scrum.id,
      accessLevel: AccessLevel.PUBLIC,
      title: 'Super Scrum',
    );
    final PictogramModel updatedPicto = await dbHandler.updatePictogram(scrum2);

    expect(updatedPicto.id, scrum2.id);
    expect(updatedPicto.title, scrum2.title);
    expect(updatedPicto.title, isNot(scrum.title));
  });

  test('Delete a pictogram from database', () async {
    final PictogramModel dbPicto = await dbHandler.createPictogram(scrum);
    expect(dbPicto.id, scrum.id);
    final bool wasDeleted = await dbHandler.deletePictogram(dbPicto.id);
    expect(wasDeleted, true);
  });

  test('Retrieve all pictograms', () async {
    await dbHandler.createPictogram(scrum);
    await dbHandler.createPictogram(extreme);
    final List<PictogramModel> pictoList = <PictogramModel>[scrum, extreme];
    final List<PictogramModel> retrievedList = await dbHandler.getAllPictograms(
        query: 'Picture', page: 0, pageSize: 10);
    expect(retrievedList[0].title, pictoList[0].title);
    expect(retrievedList[1].title, pictoList[1].title);
  });

  test('Retrieve all pictograms from a different page', () async {
    await dbHandler.createPictogram(scrum);
    await dbHandler.createPictogram(extreme);
    final List<PictogramModel> pictoList = <PictogramModel>[scrum, extreme];
    final List<PictogramModel> retrievedList = await dbHandler.getAllPictograms(
        query: 'Picture', page: 0, pageSize: 1);
    expect(retrievedList[0].title, pictoList[0].title);
    final List<PictogramModel> retrievedList2 = await dbHandler
        .getAllPictograms(query: 'Picture', page: 1, pageSize: 1);
    expect(retrievedList2[0].title, pictoList[1].title);
  });

  test('Update the image contained in a pictogram', () async {
    final String tempDir = Directory.current.path;
    Directory pictoDir;
    Directory newPictoDir;
    if (tempDir.split(separator).last == 'test') {
      pictoDir = Directory(join(tempDir, 'pictograms', 'giraf.png'));
    } else {
      pictoDir = Directory(join(tempDir, 'test', 'pictograms', 'giraf.png'));
    }
    final File pictoPath = File(pictoDir.path);
    final Uint8List pictoUInt8 = await pictoPath.readAsBytes();
    await dbHandler.createPictogram(scrum);
    await dbHandler.updateImageInPictogram(scrum.id, pictoUInt8);
    if (tempDir.split(separator).last == 'test') {
      newPictoDir = Directory(join(tempDir, 'pictograms'));
    } else {
      newPictoDir = Directory(join(tempDir, 'test', 'pictograms'));
    }
    final File newSavedPicto = File(join(newPictoDir.path, '${scrum.id}.png'));
    final Uint8List newUInt8 = await newSavedPicto.readAsBytes();
    expect(newUInt8, pictoUInt8);
    newSavedPicto.delete();
  });

  test('performs a successful login after password change', () async {
    const String oldPass = 'TestPassword123';
    const String newPass = 'TestPassword444';

    final Map<String, dynamic> body = <String, dynamic>{
      'username': jamesbondTestUser.username,
      'displayName': jamesbondTestUser.displayName,
      'password': oldPass,
      'department': jamesbondTestUser.department,
      'role': jamesbondTestUser.role.toString().split('.').last,
    };
    final GirafUserModel fakeUserRes = await dbHandler.registerAccount(body);
    final bool loginOld = await dbHandler.login(fakeUserRes.username, oldPass);
    expect(loginOld, true);
    await dbHandler.changePassword(fakeUserRes.id, newPass);
    final bool loginNew = await dbHandler.login(fakeUserRes.username, newPass);
    expect(loginNew, true);
  });

  test('performs a failed login after password change', () async {
    const String newPass = 'testPassword444';
    const String oldPass = 'TestPassword123';
    final Map<String, dynamic> body = <String, dynamic>{
      'username': jamesbondTestUser.username,
      'displayName': jamesbondTestUser.displayName,
      'password': oldPass,
      'departmentId': jamesbondTestUser.department,
      'role': jamesbondTestUser.role.toString().split('.').last,
    };
    final GirafUserModel fakeUserRes = await dbHandler.registerAccount(body);
    bool sameLogin = await dbHandler.login(fakeUserRes.username, oldPass);
    expect(sameLogin, true);
    await dbHandler.changePassword(fakeUserRes.id, newPass);
    sameLogin = await dbHandler.login(fakeUserRes.username, oldPass);
    expect(sameLogin, false);
  });

  test('Performs a account deletion action', () async {
    final GirafUserModel edUser = await dbHandler.registerAccount(edBody);
    final bool delAction = await dbHandler.deleteAccount(edUser.id);
    expect(delAction, true);
  });

  test('Attempt to delete an non-matching account', () async {
    final bool delAction = await dbHandler.deleteAccount('50');
    expect(delAction, false);
  });

  test('Get the list of citizens related to a guardian through ID', () async {
    final GirafUserModel newGuardian = GirafUserModel(
        role: Role.Guardian,
        username: 'Alex Jones',
        displayName: 'AJones',
        department: 1);

    final Map<String, dynamic> guardBody = <String, dynamic>{
      'username': newGuardian.username,
      'displayName': newGuardian.displayName,
      'password': 'pwd1234',
      'departmentId': newGuardian.department,
      'role': newGuardian.role.toString().split('.').last,
    };
    final GirafUserModel citizen1Res =
        await dbHandler.registerAccount(jamesBody);
    final GirafUserModel citizen2Res = await dbHandler.registerAccount(edBody);
    final GirafUserModel guardianRes =
        await dbHandler.registerAccount(guardBody);

    expect(citizen1Res.username, jamesbondTestUser.username);
    expect(citizen1Res.role, Role.Citizen);

    expect(citizen2Res.username, edTestUser.username);
    expect(citizen2Res.role, Role.Citizen);

    expect(guardianRes.username, newGuardian.username);
    expect(guardianRes.role, Role.Guardian);

    await dbHandler.addCitizenToGuardian(guardianRes.id, citizen1Res.id);
    await dbHandler.addCitizenToGuardian(guardianRes.id, citizen2Res.id);

    final DisplayNameModel cit1 = DisplayNameModel(
        id: citizen1Res.id,
        displayName: citizen1Res.displayName,
        role: citizen1Res.role.toString().split('.').last);

    final DisplayNameModel cit2 = DisplayNameModel(
        id: citizen2Res.id,
        displayName: citizen2Res.displayName,
        role: citizen2Res.role.toString().split('.').last);

    final List<DisplayNameModel> citizenList = <DisplayNameModel>[cit1, cit2];
    final List<DisplayNameModel> guardianList =
        await dbHandler.getCitizens(guardianRes.id);
    expect(guardianList[0].id, citizenList[0].id);
    expect(guardianList[1].id, citizenList[1].id);
    expect(guardianList[0].displayName, citizenList[0].displayName);
    expect(guardianList[1].displayName, citizenList[1].displayName);
    expect(guardianList[0].role, citizenList[0].role);
    expect(guardianList[1].role, citizenList[1].role);
  });
  test('Get the list of guardians related to a citizen through ID', () async {
    final GirafUserModel newGuardian = GirafUserModel(
        role: Role.Guardian,
        username: 'Alex Jones',
        displayName: 'AJones',
        department: 1);

    final Map<String, dynamic> guardBody = <String, dynamic>{
      'username': newGuardian.username,
      'displayName': newGuardian.displayName,
      'password': 'pwd1234',
      'departmentId': newGuardian.department,
      'role': newGuardian.role.toString().split('.').last,
    };
    final GirafUserModel newGuardian2 = GirafUserModel(
        role: Role.Guardian,
        username: 'Eminem',
        displayName: 'Em',
        department: 1);

    final Map<String, dynamic> guardBody2 = <String, dynamic>{
      'username': newGuardian2.username,
      'displayName': newGuardian2.displayName,
      'password': 'namedrop69',
      'departmentId': newGuardian2.department,
      'role': newGuardian2.role.toString().split('.').last,
    };
    final GirafUserModel citizen1Res =
        await dbHandler.registerAccount(jamesBody);
    final GirafUserModel guardian1Res =
        await dbHandler.registerAccount(guardBody);
    final GirafUserModel guardian2Res =
        await dbHandler.registerAccount(guardBody2);

    expect(citizen1Res.username, jamesbondTestUser.username);
    expect(citizen1Res.role, Role.Citizen);

    expect(guardian1Res.username, newGuardian.username);
    expect(guardian1Res.role, Role.Guardian);

    expect(guardian2Res.username, newGuardian2.username);
    expect(guardian2Res.role, Role.Guardian);

    await dbHandler.addCitizenToGuardian(guardian1Res.id, citizen1Res.id);
    await dbHandler.addCitizenToGuardian(guardian2Res.id, citizen1Res.id);

    final DisplayNameModel guard1 = DisplayNameModel(
        id: guardian1Res.id,
        displayName: guardian1Res.displayName,
        role: guardian1Res.role.toString().split('.').last);
    final DisplayNameModel guard2 = DisplayNameModel(
        id: guardian2Res.id,
        displayName: guardian2Res.displayName,
        role: guardian2Res.role.toString().split('.').last);

    final List<DisplayNameModel> guardianListexp = <DisplayNameModel>[
      guard1,
      guard2
    ];
    final List<DisplayNameModel> guardianList =
        await dbHandler.getGuardians(citizen1Res.id);
    expect(guardianList[0].id, guardianListexp[0].id);
    expect(guardianList[1].id, guardianListexp[1].id);
    expect(guardianList[0].displayName, guardianListexp[0].displayName);
    expect(guardianList[1].displayName, guardianListexp[1].displayName);
    expect(guardianList[0].role, guardianListexp[0].role);
    expect(guardianList[1].role, guardianListexp[1].role);
  });
  test('update an activity with timer is null', () async {
    final PictogramModel testPicto = await dbHandler.createPictogram(scrum);
    final File pictoImage = await addImageToPictoGram(testPicto, dbHandler);
    final GirafUserModel jamesUser = await dbHandler.registerAccount(jamesBody);
    final WeekModel userWeek = await dbHandler.updateWeek(jamesUser.id,
        blankTestWeek.weekYear, blankTestWeek.weekNumber, blankTestWeek);

    expect(userWeek.days[0].day, blankTestWeek.days[0].day);
    expect(userWeek.thumbnail.id, blankTestWeek.thumbnail.id);
    final ActivityModel testActivity = await dbHandler.addActivity(
        spise,
        jamesUser.id,
        blankTestWeek.name,
        blankTestWeek.weekYear,
        blankTestWeek.weekNumber,
        Weekday.Friday);

    blankTestWeek.days[0].activities = <ActivityModel>[testActivity];
    final ActivityModel updatedActivity =
        await dbHandler.updateActivity(testActivity, jamesUser.id);
    expect(updatedActivity.timer, null);
    await pictoImage.delete();
  });

  test('update an activity with timer', () async {
    final PictogramModel testPicto = await dbHandler.createPictogram(scrum);
    final File pictoImage = await addImageToPictoGram(testPicto, dbHandler);
    final GirafUserModel jamesUser = await dbHandler.registerAccount(jamesBody);
    final WeekModel userWeek = await dbHandler.updateWeek(jamesUser.id,
        blankTestWeek.weekYear, blankTestWeek.weekNumber, blankTestWeek);

    expect(userWeek.days[0].day, blankTestWeek.days[0].day);
    expect(userWeek.thumbnail.id, blankTestWeek.thumbnail.id);
    final ActivityModel testActivity = await dbHandler.addActivity(
        sandkasse,
        jamesUser.id,
        blankTestWeek.name,
        blankTestWeek.weekYear,
        blankTestWeek.weekNumber,
        Weekday.Friday);

    blankTestWeek.days[0].activities = <ActivityModel>[testActivity];
    final ActivityModel updatedActivity =
        await dbHandler.updateActivity(testActivity, jamesUser.id);
    expect(updatedActivity.timer.key, sandkasse.timer.key);
    await pictoImage.delete();
  });

  test('Get all weektemplate models', () async {
    final PictogramModel fakpictogram = PictogramModel(
        id: 1,
        title: 'Picto',
        lastEdit: DateTime.now(),
        imageUrl: 'http://',
        //imageHash: '#',
        accessLevel: AccessLevel.PUBLIC);
    final PictogramModel fakePictogram2 =
        await dbHandler.createPictogram(fakpictogram);
    // create fake WeekTemplateModel
    final WeekTemplateModel fakeWeekTemplate = WeekTemplateModel(
        name: 'Week 1',
        id: 1234,
        days: <WeekdayModel>[
          WeekdayModel(day: Weekday.Monday, activities: <ActivityModel>[])
        ],
        departmentKey: 5,
        thumbnail: fakePictogram2);
    //act
    // add fakeWeekTemplate to the offline database
    await dbHandler.createTemplate(fakeWeekTemplate);

    final PictogramModel fakpictogram2 = PictogramModel(
        id: 2,
        title: 'Picto',
        lastEdit: DateTime.now(),
        imageUrl: 'http://',
        //imageHash: '#',
        accessLevel: AccessLevel.PUBLIC);
    final PictogramModel fakePictogram3 =
        await dbHandler.createPictogram(fakpictogram2);
    // create fake WeekTemplateModel
    final WeekTemplateModel fakeWeekTemplate2 = WeekTemplateModel(
        name: 'Week 1',
        id: 2345,
        days: <WeekdayModel>[
          WeekdayModel(day: Weekday.Monday, activities: <ActivityModel>[])
        ],
        departmentKey: 5,
        thumbnail: fakePictogram3);
    //act
    // add fakeWeekTemplate to the offline database
    await dbHandler.createTemplate(fakeWeekTemplate2);

    final List<WeekTemplateNameModel> res = await dbHandler.getTemplateNames();
    expect(res.length, 2);
  });

  test('Get a user\'s settings', () async {
    final GirafUserModel body = await dbHandler.registerAccount(jamesBody);
    final SettingsModel res = await dbHandler.getUserSettings(body.id);
    expect(res, isNot(null));
  });

  test('Update a user setting with another setting', () async {
    final GirafUserModel body = await dbHandler.registerAccount(jamesBody);
    final SettingsModel uSettings = await dbHandler.getUserSettings(body.id);

    final SettingsModel newSettings = SettingsModel(
        orientation: orient.Orientation.Portrait,
        completeMark: CompleteMark.MovedRight,
        cancelMark: CancelMark.Removed,
        defaultTimer: DefaultTimer.Hourglass,
        timerSeconds: uSettings.timerSeconds,
        theme: GirafTheme.GirafYellow,
        nrOfDaysToDisplay: uSettings.nrOfDaysToDisplay,
        greyscale: uSettings.greyscale,
        pictogramText: uSettings.pictogramText,
        lockTimerControl: uSettings.lockTimerControl,
        activitiesCount: uSettings.activitiesCount,
        weekDayColors: uSettings.weekDayColors);
    newSettings.weekDayColors[0].hexColor = 'ffffff';

    final SettingsModel testUpdate =
        await dbHandler.updateUserSettings(body.id, newSettings);
    expect(testUpdate.cancelMark, newSettings.cancelMark);
    expect(testUpdate.completeMark, isNot(uSettings.completeMark));
  });

  test('Update a user\'s settings', () async {
    //test to be created
  });

  test('Delete an activity from weekplan', () async {
    final WeekdayModel exampleWeekDay =
        WeekdayModel(activities: null, day: Weekday.Monday);
    final List<WeekdayModel> exampleDayList = <WeekdayModel>[exampleWeekDay];
    final PictogramModel testPicto = await dbHandler.createPictogram(scrum);
    final File pictoImage = await addImageToPictoGram(testPicto, dbHandler);
    final GirafUserModel jamesUser = await dbHandler.registerAccount(jamesBody);
    final WeekModel exampleWeek = WeekModel(
        days: exampleDayList,
        thumbnail: testPicto,
        name: 'Lang ugeplan',
        weekNumber: 21,
        weekYear: 2020);
    final WeekModel userWeek = await dbHandler.updateWeek(jamesUser.id,
        exampleWeek.weekYear, exampleWeek.weekNumber, exampleWeek);

    expect(userWeek.days[0].day, exampleWeek.days[0].day);
    expect(userWeek.thumbnail.id, exampleWeek.thumbnail.id);
    final ActivityModel testActivity = await dbHandler.addActivity(
        lege,
        jamesUser.id,
        exampleWeek.name,
        exampleWeek.weekYear,
        exampleWeek.weekNumber,
        Weekday.Monday);

    exampleWeek.days[0].activities = <ActivityModel>[testActivity];
    final ActivityModel updatedActivity =
        await dbHandler.updateActivity(testActivity, jamesUser.id);
    expect(updatedActivity.id, lege.id);
    final bool delResult =
        await dbHandler.deleteActivity(updatedActivity.id, jamesUser.id);
    expect(delResult, true);
    await pictoImage.delete();
  });

  test('Create and find a pictogram', () async {
    final PictogramModel tempPicto = scrum;
    final PictogramModel pictoTest = await dbHandler.createPictogram(tempPicto);
    final String tempDir = Directory.current.path;
    Directory pictoDir;
    if (tempDir.split(separator).last == 'test') {
      pictoDir = Directory(join(tempDir, 'pictograms'));
    } else {
      pictoDir = Directory(join(tempDir, 'test', 'pictograms'));
    }
    final File pictoPath = File(join(pictoDir.path, 'giraf.png'));
    final File newPictoPath = File(join(pictoDir.path, '${tempPicto.id}.png'));
    final Uint8List testImage = await pictoPath.readAsBytes();
    await dbHandler.updateImageInPictogram(pictoTest.id, testImage);
    final Image foundImage = await dbHandler.getPictogramImage(pictoTest.id);
    expect(foundImage.image, Image.file(newPictoPath).image);
    try {
      newPictoPath.delete();
    } on FileSystemException {
      //Exception can be thrown if there is no file to delete
      //if it was never created
    }
  });
  test('Set and get a \'Me\' user', () async {
    dbHandler.setMe(jamesbondTestUser);
    expect(dbHandler.getMe(), jamesbondTestUser);
    expect(dbHandler.getMe(), isNot(edTestUser));
  });

  test('Test to create a week template in offline database', () async {
    //arrange
    //create pictogram in local db
    final PictogramModel fakpictogram = PictogramModel(
        id: 1,
        title: 'Picto',
        lastEdit: DateTime.now(),
        imageUrl: 'http://',
        //imageHash: '#',
        accessLevel: AccessLevel.PUBLIC);
    final PictogramModel fakePictogram2 =
        await dbHandler.createPictogram(fakpictogram);
    // create fake WeekTemplateModel
    final WeekTemplateModel fakeWeekTemplate = WeekTemplateModel(
        name: 'Week 1',
        id: 1234,
        days: <WeekdayModel>[
          WeekdayModel(day: Weekday.Monday, activities: <ActivityModel>[])
        ],
        departmentKey: 5,
        thumbnail: fakePictogram2);
    //act
    // add fakeWeekTemplate to the offline database
    final WeekTemplateModel createFakeWeekTemplate =
        await dbHandler.createTemplate(fakeWeekTemplate);
    //assert
    expect(fakeWeekTemplate.name, createFakeWeekTemplate.name);
  });
  // test('Test create week with a user id', () async {
  //   //arrange
  //   //Add a fake james user to offlinedb
  //   final GirafUserModel fakeUser =
  //   await dbHandler.registerAccount(jamesBody);
  //
  //   //act
  //   final WeekModel testWeek =
  //       await dbHandler.updateWeek(fakeUser.id, 2020, 1, testWeekModel);
  //   //assert
  //   expect(testWeek.weekNumber, 1);
  //   expect(testWeek.weekYear, 2020);
  // });

  test('Test changing id for a pictogram in the offline DB', () async {
    final PictogramModel testPictogram = scrum;
    testPictogram.id = 20;
    await dbHandler.createPictogram(scrum);
    await dbHandler.updateIdInOfflineDb(
        testPictogram.toJson(), 'Pictograms', scrum.id);
    final Database db = await dbHandler.database;
    final List<Map<String, dynamic>> dbRes =
        await db.rawQuery('SELECT * FROM `Pictograms` '
            "WHERE OnlineId == '${testPictogram.id}'");
    expect(dbRes.isEmpty, false);
    expect(dbRes[0]['OnlineId'], testPictogram.id);
  });

  test('Test changing id for a user in the offline DB', () async {
    final GirafUserModel testUser = jamesbondTestUser;
    testUser.id = '20';
    await dbHandler.registerAccount(jamesBody);
    await dbHandler.updateIdInOfflineDb(
        testUser.toJson(), 'Users', int.tryParse(jamesbondTestUser.id));
    final String testUserId = await dbHandler.getUserId(testUser.username);
    final GirafUserModel dbRes = await dbHandler.getUser(testUserId);
    expect(dbRes == null, false);
  });

  test('Test deletion of a week template', () async {
    //arrange
    //create pictogram in local db
    final PictogramModel fakpictogram = PictogramModel(
        id: 1,
        title: 'Picto',
        lastEdit: DateTime.now(),
        imageUrl: 'http://',
        //imageHash: '#',
        accessLevel: AccessLevel.PUBLIC);
    final PictogramModel fakePictogram2 =
        await dbHandler.createPictogram(fakpictogram);
    // create fake WeekTemplateModel
    final WeekTemplateModel fakeWeekTemplate = WeekTemplateModel(
        name: 'Week 1',
        id: 1234,
        days: <WeekdayModel>[
          WeekdayModel(day: Weekday.Monday, activities: <ActivityModel>[])
        ],
        departmentKey: 5,
        thumbnail: fakePictogram2);
    //act
    // add fakeWeekTemplate to the offline database
    await dbHandler.createTemplate(fakeWeekTemplate);
    final bool res = await dbHandler.deleteTemplate(fakeWeekTemplate.id);
    //assert
    expect(res, true);
  });
}

Future<void> cleanUsers(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.delete('`Users`');
}

Future<void> cleanSettings(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.delete('`Setting`');
}

Future<void> cleanGuardianRelations(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.delete('`GuardianRelations`');
}

Future<void> cleanWeekTemplates(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.delete('`WeekTemplates`');
}

Future<void> cleanWeek(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.delete('`Weeks`');
}

Future<void> cleanWeekdays(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.delete('`Weekdays`');
}

Future<void> cleanPictograms(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.delete('`Pictograms`');
}

Future<void> cleanActivities(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.delete('`Activities`');
}

Future<void> cleanPictogramRelations(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.delete('`PictogramRelations`');
}

Future<void> cleanTimers(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.delete('`Timers`');
}

Future<void> cleanFailedOnlineTransactions(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.delete('`FailedOnlineTransactions`');
}

Future<void> cleanWeekDayColors(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.delete('`WeekDayColors`');
}

/// Clear the testing database of all information
Future<void> killAll(OfflineDbHandler dbHandler) async {
  await cleanWeekDayColors(dbHandler);
  await cleanFailedOnlineTransactions(dbHandler);
  await cleanTimers(dbHandler);
  await cleanPictogramRelations(dbHandler);
  await cleanActivities(dbHandler);
  await cleanPictograms(dbHandler);
  await cleanWeek(dbHandler);
  await cleanWeekdays(dbHandler);
  await cleanWeekTemplates(dbHandler);
  await cleanGuardianRelations(dbHandler);
  await cleanSettings(dbHandler);
  await cleanUsers(dbHandler);
}
