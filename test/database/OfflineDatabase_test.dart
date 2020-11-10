import 'dart:io';

import 'package:api_client/models/enums/role_enum.dart';
import 'package:api_client/models/giraf_user_model.dart';
import 'package:api_client/offline_database/offline_db_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MockOfflineDbHandler extends OfflineDbHandler {
  MockOfflineDbHandler._() : super();
  @override
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
  test('performs a account register', () async {
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
      //final GirafUserModel fakeUserRes = await dbHandler.registerAccount(body);
      expect(() => dbHandler.registerAccount(body),
          throwsA(isInstanceOf<Exception>()));
      await cleanUsers(dbHandler);
    } finally {
      await cleanUsers(dbHandler);
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
