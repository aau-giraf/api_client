import 'package:api_client/models/enums/access_level_enum.dart';
import 'package:api_client/models/pictogram_model.dart';
import 'package:api_client/models/week_model.dart';
import 'package:api_client/models/week_name_model.dart';
import 'package:api_client/models/weekday_model.dart';
import 'package:api_client/api/week_api.dart';
import 'package:api_client/http/http_mock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  sqfliteFfiInit();
  WeekApi weekApi;
  HttpMock httpMock;

  setUp(() {
    httpMock = HttpMock();
    weekApi = WeekApi(httpMock);
  });

  test('Should fetch names', () {
    const String id = '1234';
    final List<WeekNameModel> names = <WeekNameModel>[
      WeekNameModel(name: 'WeekName', weekYear: 2019, weekNumber: 52),
      WeekNameModel(name: 'WeekName 2', weekYear: 2019, weekNumber: 53),
    ];

    weekApi.getNames(id).listen(expectAsync1((List<WeekNameModel> names) {
      expect(names.length, 2);
      expect(names[0].name, names[0].name);
      expect(names[0].weekYear, names[0].weekYear);
      expect(names[0].weekNumber, names[0].weekNumber);

      expect(names[1].name, names[1].name);
      expect(names[1].weekYear, names[1].weekYear);
      expect(names[1].weekNumber, names[1].weekNumber);
    }));

    httpMock
        .expectOne(url: '/$id/weekName', method: Method.get)
        .flush(<String, dynamic>{
      'data': names.map((WeekNameModel name) => name.toJson()).toList(),
      'success': true,
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should get week from week and year', () {
    const String id = '1234';
    final WeekModel week = WeekModel(
      thumbnail: PictogramModel(
        accessLevel: AccessLevel.PUBLIC,
        id: 123,
        imageHash: 'q234',
        imageUrl: 'http://google.com',
        lastEdit: DateTime.now(),
        title: 'Hello World!',
      ),
      name: 'WeekName',
      days: <WeekdayModel>[],
      weekYear: 2019,
      weekNumber: 59,
    );

    weekApi
        .get(id, week.weekYear, week.weekNumber)
        .listen(expectAsync1((WeekModel resWeek) {
      expect(resWeek.toJson(), week.toJson());
    }));

    httpMock
        .expectOne(
            url: '/$id/${week.weekYear}/${week.weekNumber}', method: Method.get)
        .flush(<String, dynamic>{
      'data': week.toJson(),
      'success': true,
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should get week from week and year', () {
    const String id = '1234';
    final WeekModel week = WeekModel(
      thumbnail: PictogramModel(
        accessLevel: AccessLevel.PUBLIC,
        id: 123,
        imageHash: 'q234',
        imageUrl: 'http://google.com',
        lastEdit: DateTime.now(),
        title: 'Hello World!',
      ),
      name: 'WeekName',
      days: <WeekdayModel>[],
      weekYear: 2019,
      weekNumber: 59,
    );

    weekApi
        .update(id, week.weekYear, week.weekNumber, week)
        .listen(expectAsync1((WeekModel resWeek) {
      expect(resWeek.toJson(), week.toJson());
    }));

    httpMock
        .expectOne(
            url: '/$id/${week.weekYear}/${week.weekNumber}', method: Method.put)
        .flush(<String, dynamic>{
      'data': week.toJson(),
      'success': true,
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should be able to delete week', () {
    const String id = '1234';
    const int year = 2019;
    const int week = 59;

    weekApi.delete(id, year, week).listen(expectAsync1((bool success) {
      expect(success, isTrue);
    }));

    httpMock
        .expectOne(url: '/$id/$year/$week', method: Method.delete)
        .flush(<String, dynamic>{
      'success': true,
      'message': '',
      'errorKey': 'NoError',
    });
  });

  tearDown(() {
    httpMock.verify();
  });
}
