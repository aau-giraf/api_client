import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Database Provider
class DbProvider {
  DbProvider._internal();

  static final DbProvider _instance = DbProvider._internal();

  /// Getter to get the instance of the Database provider
  static DbProvider get instance => _instance;

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
    final String path = join(databasesPath, 'weekplanner_local.db');

    _db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // Add tables here:
          await db.execute('CREATE TABLE username(id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'userId TEXT, userName TEXT, userRole TEXT)');
        });
    return _db;
  }
}
