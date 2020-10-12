import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

/// OfflineDbHandler is used for communication with the offline database
class OfflineDbHandler {
  OfflineDbHandler() {}
  Database _database;

  /// Initiate the database
  Future<Database> initDB() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, 'offlineGiraf.db');
    return openDatabase(path, version: 1, onOpen: (Database db) {},
        onCreate: (Database db, int version) async {
      await db.transaction((txn) async {
        await txn.execute('CREATE TABLE IF NOT EXISTS Users('
            'Id integer PRIMARY KEY, '
            'Role integer,'
            'RoleName text,'
            'Username text,'
            'DisplayName text,'
            'Department integer);');
        await txn.execute('CREATE TABLE IF NOT EXISTS guardianrelations('
            'CitizenId integer, '
            'GuardianId integer,'
            'FOREIGN KEY(CitizenId) REFERENCES citizens(Id),'
            'FOREIGN KEY(GuardianId) REFERENCES citizens(Id));');
      });
    });
  }
}
