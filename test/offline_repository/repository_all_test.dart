import 'dart:convert';

import 'package:api_client/models/displayname_model.dart';
import 'package:api_client/models/model.dart';
import 'package:api_client/offline_repository/repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mock_database.dart';

void main() {
  OfflineRepository repository;
  MockDatabase mockDatabase;

  setUp(() {
    mockDatabase = MockDatabase();
  });

  test('When result is null, should throw errer', () {
    repository = OfflineRepository('', db: mockDatabase);

    when(mockDatabase.query(any,
            distinct: null,
            columns: anyNamed('columns'),
            where: anyNamed('where'),
            whereArgs: anyNamed('whereArgs')))
        .thenAnswer((_) async => null);

    expect(repository.all(), throwsException);
  });

  test('Can get all models', () async {
    repository = OfflineRepository(
        (DisplayNameModel).toString(),
        db: mockDatabase
    );

    final DisplayNameModel firstUser =
      DisplayNameModel(displayName: 'testname', role: 'testrole', id: '1');
    final DisplayNameModel secondUser =
      DisplayNameModel(displayName: 'testname2', role: 'testrole2', id: '2');

    final String firstUserJson = json.encode(firstUser.toJson()).toString();
    final String secondUserJson = json.encode(secondUser.toJson()).toString();

    final List<Map<String, dynamic>> expectedList = <Map<String, dynamic>>[
      <String, dynamic>{'json': firstUserJson, 'offline_id': 1},
      <String, dynamic>{'json': secondUserJson, 'offline_id': 2}
    ];

    when(mockDatabase.query(any,
            distinct: null,
            columns: anyNamed('columns'),
            where: anyNamed('where'),
            whereArgs: anyNamed('whereArgs')))
        .thenAnswer((_) async => expectedList);

    final List<Model> actualList = await repository.all();

    expect(actualList, <DisplayNameModel>[firstUser, secondUser]);

    // Following only works when actualList.length == 2
    expect(actualList.length, 2);
    final DisplayNameModel actualFirst = actualList.first;
    final DisplayNameModel actualLast = actualList.last;
    expect(actualFirst.offlineId, isNotNull);
    expect(actualLast.offlineId, isNotNull);
    expect(actualFirst.offlineId, greaterThan(0));
    expect(actualLast.offlineId, greaterThan(0));
  });
}