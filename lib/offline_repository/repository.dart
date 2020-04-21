import 'package:api_client/models/model.dart';
import 'package:api_client/offline_repository/repository_interface.dart';

/// Implementation of offline repository
class OfflineRepository implements IOfflineRepository<Model> {

  /// constructor
  OfflineRepository(this._tableName);

  String _tableName;

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
  Future<Model> get(int id) {
    return null;
  }

  @override
  Future<List<Model>> all() {
    return null;
  }

}
