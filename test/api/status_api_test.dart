import 'package:api_client/api/status_api.dart';
import 'package:api_client/http/http_mock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  StatusApi statusApi;
  HttpMock httpMock;

  setUp(() {
    httpMock = HttpMock();
    statusApi = StatusApi(httpMock);
  });

  test('Should call status endpoint', () {
    statusApi.status().listen(expectAsync1((bool test) {
      expect(test, true);
    }));

    httpMock.expectOne(url: '/', method: Method.get).flush(<String, dynamic>{
      'success': true,
      'message': '',
      'errorKey': 'NoError'
    });
  });

  test('Should call database status endpoint', () {
    statusApi.databaseStatus().listen(expectAsync1((bool test) {
      expect(test, true);
    }));

    httpMock.expectOne(url: '/database', method: Method.get)
        .flush(<String, dynamic>{
      'success': true,
      'message': '',
      'errorKey': 'NoError'
    });
  });

  test('Should call version-info endpoint', () {
    const String version = 'v1';

    statusApi.versionInfo().listen(expectAsync1((String test) {
      expect(test, version);
    }));

    httpMock.expectOne(url: '/version-info', method: Method.get)
        .flush(<String, dynamic>{
      'data': version,
      'success': true,
      'message': '',
      'errorKey': 'NoError'
    });
  });

  tearDown(() {
    httpMock.verify();
  });
}
