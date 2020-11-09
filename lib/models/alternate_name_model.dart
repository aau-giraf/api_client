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
    id = json['Id'];
    citizen = json['Citizen'];
    pictogram = json['Pictogram'];
    name = json['Name'];
  }

  /// Unique id
  int id;

  /// Related citizen
  String citizen;

  /// Related pictogram
  int pictogram;

  /// Alternative name
  String name;

  @override
  ///Transform model to JSON
  Map<String, dynamic> toJson() {
    return <String, dynamic> {
      'Id' : id,
      'Citizen' : citizen,
      'Pictogram' : pictogram,
      'Name' : name
    };
  }

}