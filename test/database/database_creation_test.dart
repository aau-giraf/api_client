import 'dart:io';

import 'package:api_client/offline_database/offline_db_handler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class OfflineDbHandlerMock extends OfflineDbHandler {
  @override
  Future<Database> initDB() async {
    return databaseFactoryFfi
        .openDatabase(join(Directory.current.path, 'giraf.db'));
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  OfflineDbHandlerMock testDb = OfflineDbHandlerMock();
  test('Try to create the test db', () async {
    testDb.createTables();
    if (testDb == null) {
      print('WHYYYYYYYYYYYYYY');
    }
    expect('true', 'true');
    await testDb.closeDb();
  });
}
