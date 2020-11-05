import 'package:api_client/http/http.dart';
import 'package:api_client/models/alternate_name_model.dart';

/// AlternateName endpoints
class AlternateNameApi {
  /// constructor
  AlternateNameApi(this._http);

  final Http _http; 

  ///Create new AlternateName
  Stream<AlternateNameModel> create(AlternateNameModel an){
    return _http.post('/', an.toJson()).map((Response res) {
      return AlternateNameModel.fromJson(res.json['data']);
    });
  }
  
}