import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

class MockDatabase extends Mock implements Database {}

class MockDatabaseExecutor implements Database {
  @override
  Future<Function> execute(String sql, [List<dynamic> arguments]) {
    return null;
  }

  @override
  Batch batch() {
    return null;
  }

  @override
  Future<int> delete(String table, {String where, List<dynamic> whereArgs}) {
    return null;
  }

  @override
  Future<int> rawDelete(String sql, [List<dynamic> arguments]) {
    return null;
  }

  @override
  Future<int> update(String table, Map<String, dynamic> values,
      {String where,
      List<dynamic> whereArgs,
      ConflictAlgorithm conflictAlgorithm}) {
    return null;
  }

  @override
  Future<int> rawUpdate(String sql, [List<dynamic> arguments]) {
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(String sql,
      [List<dynamic> arguments]) {
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> query(String table,
      {bool distinct,
      List<String> columns,
      String where,
      List<dynamic> whereArgs,
      String groupBy,
      String having,
      String orderBy,
      int limit,
      int offset}) {
    return null;
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> values,
      {String nullColumnHack, ConflictAlgorithm conflictAlgorithm}) {
    return null;
  }

  @override
  Future<int> rawInsert(String sql, [List<dynamic> arguments]) {
    return null;
  }

  @override
  Future<Function> setVersion(int version) {}

  @override
  Future<int> getVersion() {}

  @override
  Future<Function> close() {}

  @override
  Future<T> devInvokeMethod<T>(String method, [dynamic arguments]) {
    throw UnimplementedError();
  }

  @override
  Future<T> devInvokeSqlMethod<T>(String method, String sql,
      [dynamic arguments]) {
    throw UnimplementedError();
  }

  @override
  bool get isOpen => throw UnimplementedError();

  @override
  String get path => throw UnimplementedError();

  @override
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action,
      {bool exclusive}) {
    throw UnimplementedError();
  }
}
