import 'package:api_client/models/giraf_user_model.dart';
import 'package:api_client/models/pictogram_model.dart';
import 'package:meta/meta.dart';

import 'model.dart';

///Alternate Name model
class AlternateNameModel implements Model {

  /// Constructor
  AlternateNameModel({
    this.id,
    this.citizen,
    this.pictogram,
    @required this.name
  });

  /// Instantiate model from JSON
  AlternateNameModel.fromJson(Map<String,dynamic> json){
    if (json == null) {
      throw const FormatException(
          '[AlternateNameModel]: Cannot initialize from null');
    }
    id = json['id'];
    citizen = json['citizen'];
    pictogram = json['pictogram'];
    name = json['name'];
  }

  /// Unique id
  int id;

  /// Related citizen
  GirafUserModel citizen;

  /// Related pictogram
  PictogramModel pictogram;

  /// Alternative name
  String name;

  @override
  ///Transform model to JSON
  Map<String, dynamic> toJson() {
    return <String, dynamic> {
      'id' : id,
      'citizen' : citizen,
      'pictogram' : pictogram,
      'name' : name
    };
  }

}