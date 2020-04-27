import 'package:api_client/offline_repository/repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mock_database.dart';
import 'test_model/test_model.dart';

void main() {

  MockDatabase mockDatabase;

  setUp(() {
    mockDatabase = MockDatabase();
  });

  test('Can insert new model', () async {
    OfflineRepository repository = OfflineRepository(
        'model',
        db: mockDatabase
    );

    TestModel model = TestModel('testName', 'testField');

    when(mockDatabase.insert(any, any)).thenAnswer((_) async => 1);

    final TestModel actual = await repository.insert(model);

    expect(model.toJson(), equals(actual.toJson()));
    expect(actual.offlineId, 1);
  });

}
