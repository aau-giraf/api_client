import 'package:api_client/api/alternate_name_api.dart';
import 'package:api_client/http/http_mock.dart';
import 'package:api_client/models/alternate_name_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main(){
  AlternateNameApi alternateNameApi;
  HttpMock httpMock;
  final AlternateNameModel mockAltName =
    AlternateNameModel(
        citizen: 'TestCitizen',
        pictogram: 7,
        name: 'Test_Alt_Title');

  setUp(() {
    httpMock = HttpMock();
    alternateNameApi = AlternateNameApi(httpMock);
  });

  test('Create Alternate Name', (){
    alternateNameApi.create(mockAltName)
          .listen(expectAsync1((AlternateNameModel an) {
      expect(an.toJson(), mockAltName.toJson());
    }));

    httpMock.expectOne(url: '/', method: Method.post).flush(<String, dynamic>{
      'data': mockAltName.toJson(),
      'success': true,
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Get Alternate Name', (){
    alternateNameApi.get(mockAltName.citizen, mockAltName.pictogram)
        .listen(expectAsync1((AlternateNameModel an) {
          expect(an.toJson(), mockAltName.toJson());
    }));

    httpMock
        .expectOne(url: '/${mockAltName.citizen}/${mockAltName.pictogram}',
        method: Method.get).flush(<String, dynamic>{
          'data': mockAltName.toJson(),
          'success': true,
          'message': '',
          'errorKey': 'NoError',
    });
  });

  test('Put Alternate Name', (){
    alternateNameApi.put(mockAltName.pictogram, mockAltName)
        .listen(expectAsync1((AlternateNameModel an) {
          expect(an.toJson(), mockAltName.toJson());
    }));

    httpMock
      .expectOne(url: '/${mockAltName.pictogram}', method: Method.put)
      .flush(<String, dynamic>{
      'data': mockAltName.toJson(),
      'success': true,
      'message': '',
      'errorKey': 'NoError',
    });
  });
}