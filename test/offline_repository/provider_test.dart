import 'package:api_client/offline_repository/provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Initial database', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    DbProvider.instance.database;
  });

}
