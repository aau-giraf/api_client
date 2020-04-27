import 'dart:convert';
import 'package:api_client/models/model.dart';
import 'package:api_client/offline_repository/db_model_factory.dart';
import 'package:api_client/offline_repository/provider.dart';
import 'package:api_client/offline_repository/repository_interface.dart';
import 'package:sqflite/sqflite.dart';
import 'exceptions.dart';

/// Database name
const String DATABASE_NAME = 'giraf_offline';

/// Implementation of offline repository
class OfflineRepository implements IOfflineRepository<Model> {

  /// Constructor
  /// The optional {DatabaseExecutor db} is for using a custom database
  OfflineRepository(this._tableName, {Database db}) {
    _externalDb = db;
  }

  final String _tableName;
  Database _database;
  Database _externalDb;

  @override
  Future<Model> insert(Model model) async {
    _database = await _prepareDb();
    final String epochNow = DateTime.now().millisecondsSinceEpoch.toString();

    final Map<String, dynamic> insertMap = <String, dynamic>{
      'json': json.encode(model.toJson()).toString(),
      'is_online': 0,
      'is_deleted': 0,
      'object': _tableName,
      'created_date': epochNow,
      'modified_date': epochNow
    };
    model.offlineId = await _database.insert(DATABASE_NAME, insertMap);
    return model;
  }

  @override
  Future<Model> update(Model model) async {
    final Map<String, dynamic> updateMap = <String, dynamic>{
      'json': json.encode(model.toJson()).toString(),
      'modified_date': DateTime.now().millisecondsSinceEpoch.toString(),
    };
    return _update(model, updateMap);
  }

  @override
  Future<Model> delete(Model model) async {
    final Map<String, dynamic> deleteMap = <String, dynamic>{
      'is_deleted': 1,
      'modified_date': DateTime.now().millisecondsSinceEpoch.toString()
    };
    return _update(model, deleteMap);
  }

  Future<Model> _update(Model model, Map<String, dynamic> updateMap) async {
    if (model.offlineId == null) {
      throw NoOfflineIdException('Offline id was null on ' + model.toString());
    }

    if (model.offlineId <= 0) {
      throw InvalidIdException('Invalid id: ' + model.offlineId.toString());
    }

    _database = await _prepareDb();
    await _database.update(
        DATABASE_NAME,
        updateMap,
        where: 'offline_id = ?',
        whereArgs: <String>[model.offlineId.toString()]
    );

    return model;
  }

  @override
  Future<Model> get(int id) async {
    _database = await _prepareDb();
    final List<Map<String, dynamic>> maps = await _database.query(
        DATABASE_NAME,
        columns: <String>['json', 'offline_id'],
        where: 'offline_id = ? AND object = ? AND is_deleted = ?',
        whereArgs: <dynamic>[id, _tableName, 0]
    );
    if (maps.isNotEmpty) {
      final Model model = ModelFactory
          .getModel(_toJson(maps.first), _tableName);
      if (model != null) {
        model.offlineId = id;
      }
      return model;
    } else {
      throw NotFoundException('Row with id ' +
          id.toString() + ' does not exist');
    }
  }

  @override
  Future<List<Model>> all() async {
    _database = await _prepareDb();
    final List<Map<String, dynamic>> maps = await _database.query(
        DATABASE_NAME,
        columns: <String>['json', 'offline_id'],
        where: 'is_deleted = ? AND object = ?',
        whereArgs: <dynamic>[0, _tableName]
    );

    if (maps != null) {
      final List<Model> models = <Model>[];
      for (Map<String, dynamic> result in maps) {
        final Model model = ModelFactory.getModel(_toJson(result), _tableName);
        if (model != null) {
          model.offlineId = result['offline_id'];
          models.add(model);
        }
      }
      return models;
    } else {
      throw OfflineDatabaseException('Result was null');
    }
  }

  /// Prepare the database
  Future<Database> _prepareDb() {
    if (_externalDb != null) {
      _database = _externalDb;
      return Future<Database>.value(_database);
    } else {
      return OfflineDbProvider.instance.database;
    }
  }

  /// to json method for db result
  Map<String, dynamic> _toJson(Map<String, dynamic> first) {
    final String jsonString = first['json'];
    return json.decode(jsonString);
  }

}
