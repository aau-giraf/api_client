
import 'package:api_client/persistence/persistence.dart';

/// Mocking for the Persistence Provider
class PersistenceMock implements Persistence {
  String _token;

  @override
  Future<String> get(String key) async {
    return _token;
  }

  @override
  Future<void> remove(String key) async {
    _token = null;
  }

  @override
  Future<void> set(String key, String value) async {
    _token = value;
  }

  @override
  Future<void> clear() async {
    _token = null;
  }

  @override
  Future<List<String>> getList(String key) async {
    return <String>[_token];
  }
}
