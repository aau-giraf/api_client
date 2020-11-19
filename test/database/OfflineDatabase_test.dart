import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:api_client/models/activity_model.dart';
import 'package:api_client/models/displayname_model.dart';
import 'package:api_client/models/enums/access_level_enum.dart';
import 'package:api_client/models/enums/activity_state_enum.dart';
import 'package:api_client/models/enums/role_enum.dart';
import 'package:api_client/models/enums/weekday_enum.dart';
import 'package:api_client/models/giraf_user_model.dart';
import 'package:api_client/models/pictogram_model.dart';
import 'package:api_client/models/timer_model.dart';
import 'package:api_client/offline_database/offline_db_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MockOfflineDbHandler extends OfflineDbHandler {
  MockOfflineDbHandler._() : super();

  static final MockOfflineDbHandler instance = MockOfflineDbHandler._();
  @override
  Future<Database> initializeDatabase() async {
    sqfliteFfiInit();
    final Database db = await databaseFactoryFfi.openDatabase(
        join(Directory.current.path, 'test', 'database', 'girafTest.db'),
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
}

final GirafUserModel jamesbondTestUser = GirafUserModel(
    username: 'JamesBond007',
    department: 1,
    displayName: 'James Bond',
    roleName: 'Citizen',
    id: 'james007bond',
    role: Role.Citizen,
    offlineId: 1);

final GirafUserModel edTestUser = GirafUserModel(
    department: 34,
    offlineId: 34,
    role: Role.Citizen,
    id: 'edmcniel01',
    roleName: 'Citizen',
    displayName: 'Ed McNiel',
    username: 'EdMcNiel34');

final PictogramModel scrum = PictogramModel(
    accessLevel: AccessLevel.PUBLIC,
    id: 44,
    title: 'Picture of Scrum',
    lastEdit: DateTime.now(),
    userId: '1');

final PictogramModel extreme = PictogramModel(
    accessLevel: AccessLevel.PROTECTED,
    id: 20,
    title: 'Picture of XP',
    lastEdit: DateTime.now(),
    userId: '3');

List<PictogramModel> testListe = <PictogramModel>[scrum];
List<PictogramModel> testListe2 = <PictogramModel>[extreme];

final ActivityModel lege = ActivityModel(
  id: 69,
  isChoiceBoard: true,
  order: 1,
  pictograms: testListe,
  choiceBoardName: 'Testchoice',
  state: ActivityState.Active,
  timer: null,
);
final TimerModel timer = TimerModel(
  startTime: DateTime.now(),
  progress: 1,
  fullLength: 10,
  paused: true,
  key: 44,
);

final ActivityModel spise = ActivityModel(
  id: 70,
  pictograms: testListe2,
  order: 2,
  state: ActivityState.Active,
  isChoiceBoard: true,
  choiceBoardName: 'Testsecondchoice',
  timer: null,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  final MockOfflineDbHandler dbHandler = MockOfflineDbHandler.instance;
  test('Try to create the test db', () async {
    expect(await dbHandler.getCurrentDBVersion(), 1);
    // We might need this if somthing is wrong
    // in the tests and it doesn't close itself
    //dbHandler.closeDb();
  });
  test('Register an account in the offline db', () async {
    //create fake account
    try {
      final Map<String, dynamic> body = <String, dynamic>{
        'username': jamesbondTestUser.username,
        'displayName': jamesbondTestUser.displayName,
        'password': 'TestPassword123',
        'departmentId': jamesbondTestUser.department,
        'role': jamesbondTestUser.role.toString().split('.').last,
      };
      final GirafUserModel fakeUserRes = await dbHandler.registerAccount(body);
      expect(fakeUserRes.username, jamesbondTestUser.username);
      expect(fakeUserRes.displayName, jamesbondTestUser.displayName);
      expect(fakeUserRes.role, Role.Citizen);
    } finally {
      cleanUsers(dbHandler);
    }
  });
  test('Test if it is possible to register the same account twice', () async {
    try {
      //create fake account
      final Map<String, dynamic> body = <String, dynamic>{
        'username': edTestUser.username,
        'displayName': edTestUser.displayName,
        'password': 'TestPassword123',
        'departmentId': edTestUser.department,
        'role': edTestUser.role.toString().split('.').last,
      };
      await dbHandler.registerAccount(body);
      expect(() => dbHandler.registerAccount(body),
          throwsA(isInstanceOf<Exception>()));
      await cleanUsers(dbHandler);
    } finally {
      await cleanUsers(dbHandler);
    }
  });
  test('Add activity test', () async {
    try {
      //arrange
      //create fake account
      final Map<String, dynamic> body = <String, dynamic>{
        'username': jamesbondTestUser.username,
        'displayName': jamesbondTestUser.displayName,
        'password': 'TestPassword123',
        'departmentId': jamesbondTestUser.department,
        'role': jamesbondTestUser.role.toString().split('.').last,
      };
      //create fake user
      //add pictograms to offline database
      final PictogramModel fakePicto1 = await dbHandler.createPictogram(scrum);
      final PictogramModel fakePicto2 =
          await dbHandler.createPictogram(extreme);
      //act
      lege.pictograms = <PictogramModel>[fakePicto1, fakePicto2];
      final ActivityModel fakeactivityModel = await dbHandler.addActivity(
          lege, '1', 'weekplanName', 2020, 50, Weekday.Friday);
      //assert
      expect(lege.id, fakeactivityModel.id);
      expect(lege.state, fakeactivityModel.state);
    } finally {
      await cleanActivities(dbHandler);
      await cleanUsers(dbHandler);
      await cleanPictograms(dbHandler);
      await cleanPictogramRelations(dbHandler);
    }
  });

  test('Perform a correct login attempt', () async {
    try {
      const String testPassword = 'MyPassword32';
      final Map<String, dynamic> dbUser = <String, dynamic>{
        'username': jamesbondTestUser.username,
        'displayName': jamesbondTestUser.displayName,
        'password': testPassword,
        'departmentId': jamesbondTestUser.department,
        'role': jamesbondTestUser.role.toString().split('.').last,
      };
      await dbHandler.registerAccount(dbUser);
      final bool testLogin =
          await dbHandler.login(jamesbondTestUser.username, testPassword);
      expect(testLogin, true);
    } finally {
      await cleanUsers(dbHandler);
    }
  });

  test('Perform a correct login attempt 2', () async {
    try {
      const String testPassword = 'hunter2';
      final Map<String, dynamic> dbUser = <String, dynamic>{
        'username': jamesbondTestUser.username,
        'displayName': jamesbondTestUser.displayName,
        'password': testPassword,
        'departmentId': jamesbondTestUser.department,
        'role': jamesbondTestUser.role.toString().split('.').last,
      };
      await dbHandler.registerAccount(dbUser);
      final bool testLogin =
          await dbHandler.login(jamesbondTestUser.username, testPassword);
      expect(testLogin, true);
    } finally {
      await cleanUsers(dbHandler);
    }
  });

  test('Perform a incorrect login attempt', () async {
    try {
      const String testPassword = 'MyPassword32';
      const String wrongPassword = 'PasswordGuess128';
      final Map<String, dynamic> dbUser = <String, dynamic>{
        'username': jamesbondTestUser.username,
        'displayName': jamesbondTestUser.displayName,
        'password': testPassword,
        'departmentId': jamesbondTestUser.department,
        'role': jamesbondTestUser.role.toString().split('.').last,
      };
      await dbHandler.registerAccount(dbUser);
      final bool testLogin =
          await dbHandler.login(jamesbondTestUser.username, wrongPassword);
      expect(testLogin, false);
    } finally {
      await cleanUsers(dbHandler);
    }
  });

  test('Perform a incorrect login attempt 2', () async {
    try {
      const String testPassword = 'hejmeddig123';
      const String wrongPassword = 'Hejmeddig123';
      final Map<String, dynamic> dbUser = <String, dynamic>{
        'username': jamesbondTestUser.username,
        'displayName': jamesbondTestUser.displayName,
        'password': testPassword,
        'departmentId': jamesbondTestUser.department,
        'role': jamesbondTestUser.role.toString().split('.').last,
      };
      await dbHandler.registerAccount(dbUser);
      final bool testLogin =
          await dbHandler.login(jamesbondTestUser.username, wrongPassword);
      expect(testLogin, false);
    } finally {
      await cleanUsers(dbHandler);
    }
  });
  test('Create a pictogram in the offline database', () async {
    try {
      await dbHandler.createPictogram(scrum);
      final PictogramModel dbPicto = await dbHandler.getPictogramID(scrum.id);
      expect(dbPicto.id, scrum.id);
    } finally {
      await cleanPictograms(dbHandler);
    }
  });

  test('Update existing pictogram in database', () async {
    try {
      await dbHandler.createPictogram(scrum);
      final PictogramModel scrum2 = scrum;
      scrum2.title = 'Super Scrum';
      final PictogramModel updatedPicto =
          await dbHandler.updatePictogram(scrum2);

      expect(updatedPicto.id, scrum2.id);
      expect(updatedPicto.title, scrum2.title);
    } finally {
      await cleanPictograms(dbHandler);
    }
  });

  test('Delete a pictogram from database', () async {
    try {
      final PictogramModel dbPicto = await dbHandler.createPictogram(scrum);
      expect(dbPicto.id, scrum.id);
      final bool wasDeleted = await dbHandler.deletePictogram(dbPicto.id);
      expect(wasDeleted, true);
    } finally {
      await cleanPictograms(dbHandler);
    }
  });

  test('Update the image contained in a pictogram', () async {
    try {
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
      final File newSavedPicto =
          File(join(newPictoDir.path, '${scrum.id}.png'));
      final Uint8List newUInt8 = await newSavedPicto.readAsBytes();
      expect(newUInt8, pictoUInt8);
      newSavedPicto.delete();
    } finally {
      await cleanPictograms(dbHandler);
    }
  });

  test('performs a successful login after password change', () async {
    try {
      const String oldPass = 'TestPassword123';
      const String newPass = 'TestPassword444';

      final Map<String, dynamic> body = <String, dynamic>{
        'username': jamesbondTestUser.username,
        'displayName': jamesbondTestUser.displayName,
        'password': oldPass,
        'departmentId': jamesbondTestUser.department,
        'role': jamesbondTestUser.role.toString().split('.').last,
      };
      final GirafUserModel fakeUserRes = await dbHandler.registerAccount(body);
      final bool loginOld =
          await dbHandler.login(fakeUserRes.username, oldPass);
      expect(loginOld, true);
      await dbHandler.changePassword(fakeUserRes.id, newPass);
      final bool loginNew =
          await dbHandler.login(fakeUserRes.username, newPass);
      expect(loginNew, true);
    } finally {
      await cleanUsers(dbHandler);
    }
  });

  test('performs a failed login after password change', () async {
    try {
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
    } finally {
      cleanUsers(dbHandler);
    }
  });

  test('Performs a account deletion action', () async {
    try {
      final Map<String, dynamic> body = <String, dynamic>{
        'username': edTestUser.username,
        'displayName': edTestUser.displayName,
        'password': 'TestPassword123',
        'departmentId': edTestUser.department,
        'role': edTestUser.role.toString().split('.').last,
      };
      await dbHandler.registerAccount(body);
      final String user = await dbHandler.getUserId(edTestUser.username);
      expect(() => dbHandler.deleteAccount(user),
          throwsA(isInstanceOf<Exception>()));
    } finally {
      await cleanUsers(dbHandler);
    }
  });

  test('Get the list of citizens with a guardian relation', () async {
    try {
      final GirafUserModel newGuardian = GirafUserModel(
          role: Role.Guardian,
          username: 'Alex Jones',
          displayName: 'AJones',
          department: 1);
      final Map<String, dynamic> cit1Body = <String, dynamic>{
        'username': jamesbondTestUser.username,
        'displayName': jamesbondTestUser.displayName,
        'password': 'pwd1234',
        'departmentId': jamesbondTestUser.department,
        'role': jamesbondTestUser.role.toString().split('.').last,
      };

      final Map<String, dynamic> cit2Body = <String, dynamic>{
        'username': edTestUser.username,
        'displayName': edTestUser.displayName,
        'password': 'pwd1234',
        'departmentId': edTestUser.department,
        'role': edTestUser.role.toString().split('.').last,
      };
      final Map<String, dynamic> guardBody = <String, dynamic>{
        'username': newGuardian.username,
        'displayName': newGuardian.displayName,
        'password': 'pwd1234',
        'departmentId': newGuardian.department,
        'role': newGuardian.role.toString().split('.').last,
      };

      final GirafUserModel citizen1Res =
          await dbHandler.registerAccount(cit1Body);
      final GirafUserModel citizen2Res =
          await dbHandler.registerAccount(cit2Body);
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
    } finally {
      await cleanUsers(dbHandler);
      await cleanGuardianRelations(dbHandler);
    }
  });
  test('update an activity', () async {
    try {
      final Map<String, dynamic> jamesBondBody = <String, dynamic>{
        'username': jamesbondTestUser.username,
        'displayName': jamesbondTestUser.displayName,
        'Rolename': jamesbondTestUser.roleName,
        'offlineid': jamesbondTestUser.offlineId,
        'id': jamesbondTestUser.id,
        'Role': jamesbondTestUser.role,
        'password': '007'
      };
      await dbHandler.registerAccount(jamesBondBody);
      final PictogramModel fakePictogram =
          await dbHandler.createPictogram(scrum);
      lege.pictograms = [fakePictogram];
      ActivityModel model = await dbHandler.addActivity(
          lege, '33', 'weekplanName', 2020, 43, Weekday.Monday);
      model.order = 0;
      final ActivityModel res = await dbHandler.updateActivity(model, '33');
      expect(res.order, 0);
    } finally {
      await cleanPictogramRelations(dbHandler);
      await cleanUsers(dbHandler);
      await cleanActivities(dbHandler);
      await cleanPictograms(dbHandler);
    }
  });
}

Future<void> cleanUsers(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.rawDelete('DELETE FROM `Users`');
}

Future<void> cleanSettings(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.rawDelete('DELETE FROM `Setting`');
}

Future<void> cleanGuardianRelations(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.rawDelete('DELETE FROM `GuardianRelations`');
}

Future<void> cleaWeekTemplates(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.rawDelete('DELETE FROM `WeekTemplates`');
}

Future<void> cleanWeek(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.rawDelete('DELETE FROM `Weeks`');
}

Future<void> cleanWeekdays(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.rawDelete('DELETE FROM `Weekdays`');
}

Future<void> cleanPictograms(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.rawDelete('DELETE FROM `Pictograms`');
}

Future<void> cleanActivities(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.rawDelete('DELETE FROM `Activities`');
}

Future<void> cleanPictogramRelations(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.rawDelete('DELETE FROM `PictogramRelations`');
}

Future<void> cleanTimers(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.rawDelete('DELETE FROM `Timers`');
}

Future<void> cleanFailedOnlineTransactions(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.rawDelete('DELETE FROM `FailedOnlineTransactions`');
}

Future<void> cleanWeekDayColors(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.rawDelete('DELETE FROM `WeekDayColors`');
}
