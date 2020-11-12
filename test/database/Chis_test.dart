//import 'dart:html';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:api_client/models/activity_model.dart';
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
import 'package:path/path.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'OfflineDatabase_test.dart';

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
    title: 'Pacture of Scrum',
    /*imageHash: File(join(Directory.current.path, 'test',
     'giraf.png')).hashCode.toString(),
    imageUrl: ,*/
    lastEdit: DateTime.now(),
    userId: '1');

final PictogramModel extreme = PictogramModel(
    accessLevel: AccessLevel.PROTECTED,
    id: 20,
    title: 'Pacture of XP',
    /*imageHash: File(join(Directory.current.path, 'test',
     'giraf.png')).hashCode.toString(),
    imageUrl: ,*/
    lastEdit: DateTime.now(),
    userId: '3');

List<PictogramModel> testListe = [scrum];
List<PictogramModel> testListe2 = [extreme];

final ActivityModel lege = ActivityModel(
    id: 69,
    isChoiceBoard: true,
    order: 4,
    pictograms: testListe,
    choiceBoardName: 'Testchoice',
    state: ActivityState.Active,
    timer: null);

final ActivityModel spise = ActivityModel(
    id: 70,
    pictograms: testListe2,
    order: 44,
    state: ActivityState.Active,
    isChoiceBoard: true,
    timer: null);
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  test('Try to create the test db', () async {
    expect(await MockOfflineDbHandler.instance.getCurrentDBVersion(), 1);
    // We might need this if somthing is wrong
    // in the tests and it doesn't close itself
    //testDb.closeDb();
  });
  test('Register an account in the offline db', () async {
    final OfflineDbHandler dbHandler = MockOfflineDbHandler.instance;
    //create fake account
    const String testUsername = 'BobJensen123';
    final GirafUserModel fakeAccount = GirafUserModel(
        role: Role.Citizen,
        username: testUsername,
        displayName: 'Bob Jensen',
        department: 1);
    final Map<String, dynamic> body = <String, dynamic>{
      'username': fakeAccount.username,
      'displayName': fakeAccount.displayName,
      'password': 'TestPassword123',
      'departmentId': fakeAccount.department,
      'role': fakeAccount.role.toString().split('.').last,
    };
    final GirafUserModel fakeUserRes = await dbHandler.registerAccount(body);
    expect(fakeUserRes.username, testUsername);
    expect(fakeUserRes.role, Role.Citizen);
  });
  test('Test if it is possible to register the same account twice', () async {
    final OfflineDbHandler dbHandler = MockOfflineDbHandler.instance;
    try {
      //create fake account
      const String testUsername = 'BobJensen123';
      final GirafUserModel fakeAccount = GirafUserModel(
          role: Role.Citizen,
          username: testUsername,
          displayName: 'Bob Jensen',
          department: 1);
      final Map<String, dynamic> body = <String, dynamic>{
        'username': fakeAccount.username,
        'displayName': fakeAccount.displayName,
        'password': 'TestPassword123',
        'departmentId': fakeAccount.department,
        'role': fakeAccount.role.toString().split('.').last,
      };
      expect(() => dbHandler.registerAccount(body),
          throwsA(isInstanceOf<Exception>()));
      await cleanUsers(dbHandler);
    } finally {
      await cleanUsers(dbHandler);
    }
  });
  test('Add activity test', () async {
    //arrange
    final OfflineDbHandler dbHandler = MockOfflineDbHandler.instance;
    // final List<PictogramModel> fakePictograms = <PictogramModel>[];
    // final ActivityModel fakeActivity = ActivityModel(
    //     pictograms: fakePictograms,
    //     order: 1,
    //     id: 1,
    //     state: ActivityState.Normal,
    //     isChoiceBoard: true);
    //create fake account
    const String testUsername = 'BobJensen123';
    final GirafUserModel fakeAccount = GirafUserModel(
        role: Role.Citizen,
        username: testUsername,
        displayName: 'Bob Jensen',
        department: 1);
    final Map<String, dynamic> body = <String, dynamic>{
      'username': fakeAccount.username,
      'displayName': fakeAccount.displayName,
      'password': 'TestPassword123',
      'departmentId': fakeAccount.department,
      'role': fakeAccount.role.toString().split('.').last,
    };
    final GirafUserModel fakeUserRes = await dbHandler.registerAccount(body);
    //final Weekday fakeDay = Weekday(;
    //act
    // final ActivityModel fakeactivityModel = await dbHandler.addActivity(
    //     fakeActivity, '1', 'weekplanName', 2020, 50, Weekday.Friday);
    //assert
    expect(fakeUserRes.username, testUsername);
  });
  test('Perform a correct login attempt', () async {
    final MockOfflineDbHandler testdb = MockOfflineDbHandler.instance;
    const String testPassword = 'MyPassword32';
    final GirafUserModel testAcc = GirafUserModel(
        role: Role.Citizen,
        username: 'TestTest',
        displayName: 'Test Testersen',
        department: 1);
    final Map<String, dynamic> dbUser = <String, dynamic>{
      'username': testAcc.username,
      'displayName': testAcc.displayName,
      'password': testPassword,
      'departmentId': testAcc.department,
      'role': testAcc.role.toString().split('.').last,
    };
    await testdb.registerAccount(dbUser);
    final bool testLogin = await testdb.login(testAcc.username, testPassword);
    expect(testLogin, true);
    await cleanUsers(testdb);
  });

  test('Perform a correct login attempt 2', () async {
    final MockOfflineDbHandler testdb = MockOfflineDbHandler.instance;
    const String testPassword = 'hunter2';
    final GirafUserModel testAcc = GirafUserModel(
        role: Role.Citizen,
        username: 'PJacobsen',
        displayName: 'Peter Jacobsen',
        department: 2);
    final Map<String, dynamic> dbUser = <String, dynamic>{
      'username': testAcc.username,
      'displayName': testAcc.displayName,
      'password': testPassword,
      'departmentId': testAcc.department,
      'role': testAcc.role.toString().split('.').last,
    };
    await testdb.registerAccount(dbUser);
    final bool testLogin = await testdb.login(testAcc.username, testPassword);
    expect(testLogin, true);
    await cleanUsers(testdb);
  });

  test('Perform a wrong login attempt', () async {
    final MockOfflineDbHandler testdb = MockOfflineDbHandler.instance;
    const String testPassword = 'MyPassword32';
    const String wrongPassword = 'PasswordGuess128';
    final GirafUserModel testAcc = GirafUserModel(
        role: Role.Citizen,
        username: 'TestTest',
        displayName: 'Test Testersen',
        department: 1);
    final Map<String, dynamic> dbUser = <String, dynamic>{
      'username': testAcc.username,
      'displayName': testAcc.displayName,
      'password': testPassword,
      'departmentId': testAcc.department,
      'role': testAcc.role.toString().split('.').last,
    };
    await testdb.registerAccount(dbUser);
    final bool testLogin = await testdb.login(testAcc.username, wrongPassword);
    expect(testLogin, false);
    await cleanUsers(testdb);
  });

  test('Perform a wrong login attempt 2', () async {
    final MockOfflineDbHandler testdb = MockOfflineDbHandler.instance;
    const String testPassword = 'hejmeddig123';
    const String wrongPassword = 'Hejmeddig123';
    final GirafUserModel testAcc = GirafUserModel(
        role: Role.Citizen,
        username: 'SimOestGaard',
        displayName: 'Simon Østergård',
        department: 2);
    final Map<String, dynamic> dbUser = <String, dynamic>{
      'username': testAcc.username,
      'displayName': testAcc.displayName,
      'password': testPassword,
      'departmentId': testAcc.department,
      'role': testAcc.role.toString().split('.').last,
    };
    await testdb.registerAccount(dbUser);
    final bool testLogin = await testdb.login(testAcc.username, wrongPassword);
    expect(testLogin, false);
    await cleanUsers(testdb);
  });
  test('performs a successfull change of password ', () async {
    final OfflineDbHandler dbHandler = MockOfflineDbHandler.instance;
    try {
      const String testUsername = 'ChrisAaen11';
      final GirafUserModel changepassword = GirafUserModel(
          role: Role.Citizen,
          username: testUsername,
          displayName: 'Chris Aaen',
          department: 1);
      final Map<String, dynamic> body = <String, dynamic>{
        'username': changepassword.username,
        'displayName': changepassword.displayName,
        'password': 'TestPassword123',
        'departmentId': changepassword.department,
        'role': changepassword.role.toString().split('.').last,
      };
      final GirafUserModel fakeUserRes = await dbHandler.registerAccount(body);
      await dbHandler.changePassword(fakeUserRes.id, 'TestPassword444');
      final bool res = await dbHandler.login('ChrisAaen11', 'TestPassword444');
      expect(res, true);
    } finally {
      await cleanUsers(dbHandler);
    }
  });

  test('performs a falied change of password ', () async {
    final OfflineDbHandler dbHandler = MockOfflineDbHandler.instance;
    try {
      const String testUsername = 'BrianJohnson44';
      final GirafUserModel changepassword = GirafUserModel(
          role: Role.Citizen,
          username: testUsername,
          displayName: 'Brian Johnson',
          department: 1);
      final Map<String, dynamic> body = <String, dynamic>{
        'username': changepassword.username,
        'displayName': changepassword.displayName,
        'password': 'TestPassword123',
        'departmentId': changepassword.department,
        'role': changepassword.role.toString().split('.').last,
      };
      final GirafUserModel fakeUserRes = await dbHandler.registerAccount(body);
      await dbHandler.changePassword(fakeUserRes.id, 'TestPassword444');
      final bool res = await dbHandler.login('ChrisAaen11', 'TestPassword6969');
      expect(res, false);
    } finally {
      await cleanUsers(dbHandler);
    }
  });

  test('performs an update to activities', () async {
    final OfflineDbHandler dbHandler = MockOfflineDbHandler.instance;
    try {
      final Map<String, dynamic> jamesBondBody = <String, dynamic>{
        'username': jamesbondTestUser.username,
        'displayname': jamesbondTestUser.displayName,
        'Rolename': jamesbondTestUser.roleName,
        'offlineid': jamesbondTestUser.offlineId,
        'id': jamesbondTestUser.id,
        'Role': jamesbondTestUser.role
      };
      await dbHandler.registerAccount(jamesBondBody);
      await dbHandler.createPictogram(scrum);
      await dbHandler.addActivity(
          lege, '33', 'weekplanName', 2020, 43, Weekday.Monday);
      final ActivityModel res =
          await dbHandler.updateActivity(spise, 'en spise aktivitet');
          expect(res, spise);
    } finally {
      await cleanActivities(dbHandler);
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
  db.rawDelete('DELETE * FROM `Setting`');
}

Future<void> cleanGaurdianRelations(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  db.rawDelete('DELETE * FROM `GuardianRelations`');
}

Future<void> cleaWeekTemplates(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  db.rawDelete('DELETE * FROM `WeekTemplates`');
}

Future<void> cleanWeek(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  db.rawDelete('DELETE * FROM `Weeks`');
}

Future<void> cleanWeekdays(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  db.rawDelete('DELETE * FROM `Weekdays`');
}

Future<void> cleanPictograms(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  db.rawDelete('DELETE * FROM `Pictograms`');
}

Future<void> cleanActivities(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  db.rawDelete('DELETE * FROM `Activities`');
}

Future<void> cleanPictogramRelations(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  db.rawDelete('DELETE * FROM `PictogramRelations`');
}

Future<void> cleanTimers(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  db.rawDelete('DELETE * FROM `Timers`');
}

Future<void> cleanFailedOnlineTransactions(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  db.rawDelete('DELETE * FROM `FailedOnlineTransactions`');
}

Future<void> cleanWeekDayColors(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  db.rawDelete('DELETE * FROM `WeekDayColors`');
}
