import 'package:api_client/models/model.dart';
import 'package:api_client/offline_repository/repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock_database.dart';
import 'test_model/test_model.dart';

void main() {

  MockDatabase mockDatabase;
  OfflineRepository repository;

  setUp(() {
    mockDatabase = MockDatabase();
  });

  test('If offline id on model is null, should throw error', () {
    repository = OfflineRepository('', db: mockDatabase);
    final Model testModel = TestModel('name', 'field');
    testModel.offlineId = null;

    expect(() => repository.update(testModel), throwsException);
  });

  test('If offline id on model is invalid, should throw error', () {
    repository = OfflineRepository('', db: mockDatabase);
    final Model testModel = TestModel('name', 'field');
    testModel.offlineId = -1;

    expect(() => repository.update(testModel), throwsException);
  });

}