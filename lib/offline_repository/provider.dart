import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Database Provider
class OfflineDbProvider {
  OfflineDbProvider._internal();

  static final OfflineDbProvider _instance = OfflineDbProvider._internal();

  /// Getter to get the instance of the Database provider
  static OfflineDbProvider get instance => _instance;

  Database _db;

  /// Getter for the database
  Future<Database> get database async {
    if (_db != null) {
      return _db;
    }
    _db = await _init();
    return _db;
  }

  Future<Database> _init() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, 'eweekplanner_local.db');

    _db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // Executing of initial tables here
          await db.execute(readInitialTablesQuery());
        });
    return _db;
  }

  /// Read the initial tables query
  String readInitialTablesQuery() {
    return 'CREATE TABLE IF NOT EXISTS giraf_offline('
        'offline_id INTEGER PRIMARY KEY,'
        'json BLOB NOT NULL,'
        'is_online INTEGER,'
        'is_deleted INTEGER DEFAULT 0,'
        'object TEXT NOT NULL,'
        'created_date TEXT NOT NULL,'
        'modified_date TEXT NOT NULL);';
  }

}
