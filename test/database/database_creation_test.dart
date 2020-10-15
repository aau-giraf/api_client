import 'dart:io';

import 'package:api_client/offline_database/offline_db_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  sqfliteFfiInit();
  final OfflineDbHandler testDb = OfflineDbHandler(await databaseFactoryFfi
      .openDatabase(join(Directory.current.path, 'database', 'girafTest.db')));
  test('Try to create the test db', () async {
    expect(await testDb.getCurrentDBVersion(), 0);
    // We might need this if somthing is wrong
    // in the tests and it doesn't close itself
    //testDb.closeDb();
  });
}
