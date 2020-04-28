import 'package:api_client/models/model.dart';

/// Interface for offline repository
abstract class IOfflineRepository<T extends Model> {

  /// Insert method for a model
  Future<T> insert(T model);

  /// Update method for a model
  Future<T> update(T model);

  /// Delete method for a model
  Future<T> delete(T model);

  /// Get method for a model
  Future<T> get(int id);

  /// Get all instances of a model
  Future<List<T>> all();

}
