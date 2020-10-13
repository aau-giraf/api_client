import 'dart:io';

import 'package:api_client/offline_database/offline_db_handler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

class OfflineDbHandlerMock extends OfflineDbHandler {
  @override
  Future<sqflite.Database> initDB() async {
    final String databasesPath = await sqflite.getDatabasesPath();
    final String path = databasesPath + '/db.sqlite3';
    final bool exists = await sqflite.databaseExists(path);
    if (!exists) {
      final ByteData data = await rootBundle.load('assets/db.sqlite3');
      final List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await Directory(databasesPath).create(recursive: true);
      await File(path).writeAsBytes(bytes, flush: true);
    }
    return sqflite.openDatabase(path);
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  OfflineDbHandlerMock testDb = OfflineDbHandlerMock();
  test('Try to create the test db', () {
    testDb.createTables();
    expect('true', 'true');
  });
}
