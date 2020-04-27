import 'dart:convert';
import 'package:api_client/models/model.dart';
import 'package:api_client/offline_repository/db_model_factory.dart';
import 'package:api_client/offline_repository/exceptions/not_found.dart';
import 'package:api_client/offline_repository/provider.dart';
import 'package:api_client/offline_repository/repository_interface.dart';
import 'package:sqflite/sqflite.dart';

/// Implementation of offline repository
class OfflineRepository implements IOfflineRepository<Model> {

  /// constructor
  /// The optional {DatabaseExecutor db} is for using a custom database
  OfflineRepository(this._tableName, {Database db}) {
    init(db: db);
  }

  /// Initial database connection
  Future<Database> init({Database db}) async {
    if (db != null) {
      _db = db;
      return db;
    } else {
      _db = await DbProvider.instance.database;
      return _db;
    }
  }

  final String _tableName;

  Database _db;

  @override
  Future<Model> insert(Model model) async {
    final Map<String, dynamic> insertMap = <String, dynamic>{
      'json': json.encode(model.toJson()).toString(),
      'is_online': 0,
      'is_deleted': 0,
      'object': _tableName,
      'created_date': 0,
      'modified_date': 0
    };
    model.offlineId = await _db.insert('giraf_offline', insertMap);
    return model;
  }

  @override
  Future<Model> update(Model model) {
    return null;
  }

  @override
  Future<Model> delete(Model model) {
    return null;
  }

  @override
  Future<Model> get(int id) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'giraf_offline',
      columns: <String>['json', 'offline_id'],
      where: 'offline_id = ? AND object = ? AND is_deleted = ?',
      whereArgs: <dynamic>[id, _tableName, false]
    );
    if (maps.isNotEmpty) {
      final Model model = ModelFactory.getModel(toJson(maps.first), _tableName);
      if (model != null) {
        model.offlineId = id;
      }
      return model;
    } else {
      throw NotFound('Row with id ' + id.toString() + ' does not exist');
    }
  }

  @override
  Future<List<Model>> all() {
    return null;
  }

  /// to json method for db result
  Map<String, dynamic> toJson(Map<String, dynamic> first) {
    final String jsonString = first['json'];
    return json.decode(jsonString);
  }

}
