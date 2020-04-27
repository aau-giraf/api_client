import 'dart:convert';

import 'package:api_client/models/model.dart';
import 'package:api_client/models/username_model.dart';
import 'package:api_client/offline_repository/exceptions.dart';
import 'package:api_client/offline_repository/repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'mock_database.dart';

void main() {

  MockDatabase mockDatabase;
  OfflineRepository repository;

  setUp(() {
    mockDatabase  = MockDatabase();
  });

  test('When model not recognized by model factory, expect null', () async {
    repository = OfflineRepository('', db: mockDatabase);

    when(mockDatabase.query(any,
        distinct: null,
        columns: anyNamed('columns'),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs')))
        .thenAnswer((_) async =>
    [
      <String, dynamic>{'json': '{"Hejsa": "Hjesa"}'}
    ]);

    final Model response = await repository.get(1);

    // We expect null because the factory cannot recognize ''
    expect(response, isNull);
    verify(mockDatabase.query(any,
        distinct: null,
        columns: anyNamed('columns'),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs')));
    verifyNoMoreInteractions(mockDatabase);
  });

  test('When model exists and is recognized, should return model', () async {
    repository = OfflineRepository(
        (UsernameModel).toString(),
        db: mockDatabase
    );

    UsernameModel usernameModel = UsernameModel(
      name: 'name',
      role: 'role',
      id: '1',
    );
    String usernameModelJson = json.encode(usernameModel.toJson()).toString();

    when(mockDatabase.query(any,
        distinct: null,
        columns: anyNamed('columns'),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs')))
        .thenAnswer((_) async =>
    [
      <String, dynamic>{'json': usernameModelJson}
    ]);

    // Test will pass for any id > 0
    final Model actualModel = await repository.get(1);

    expect(actualModel, isInstanceOf<UsernameModel>());
    expect(actualModel.toJson(), equals(usernameModel.toJson()));
    expect(actualModel.getOfflineId(), isNotNull);
    expect(actualModel.getOfflineId(), greaterThan(0));
  });

  test('When id not found, should raise error', () {
    repository = OfflineRepository('', db: mockDatabase);

    when(mockDatabase.query(any,
        distinct: null,
        columns: anyNamed('columns'),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'))).thenThrow(NotFoundException(''));

    expect(repository.get(1), throwsException);
  });
}
