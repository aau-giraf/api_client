import 'dart:io';

import 'package:api_client/offline_database/offline_db_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  test('Try to create the test db', () async {
    Database test = await databaseFactoryFfi
        .openDatabase(join(Directory.current.path, 'girafTest.db'));
    OfflineDbHandler testDb = OfflineDbHandler(test);

    if (testDb == null) {
      print('WHYYYYYYYYYYYYYY');
    }
    await testDb.createTables();
    expect('true', 'true');
    //testDb.closeDb();
  });
}
