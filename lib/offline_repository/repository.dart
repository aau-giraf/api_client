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
  OfflineRepository(this._tableName) {
    init();
  }

  /// Initial database connection
  Future<Database> init() async {
    _db = await DbProvider.instance.database;
    return _db;
  }

  final String _tableName;

  Database _db;

  @override
  Future<Model> insert(Model model) {
    return null;
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
      columns: <String>['json'],
      where: 'id = ? AND class_name = ? AND is_deleted = ?',
      whereArgs: <dynamic>[id, _tableName, false]
    );
    if (maps.isNotEmpty) {
      return ModelFactory.getModel(toJson(maps.first), _tableName);
    } else {
      throw NotFound('Row with id ' + id.toString() + ' does not exist');
    }
  }

  @override
  Future<List<Model>> all() {
    return null;
  }

  Map<String, dynamic> toJson(Map<String, dynamic> first) {
    final String jsonString = first['json'];
    return json.decode(jsonString);
  }

}
