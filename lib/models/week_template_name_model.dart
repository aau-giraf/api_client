import 'package:api_client/models/model.dart';
import 'package:api_client/offline_repository/repository.dart';
import 'package:api_client/offline_repository/repository_interface.dart';

/// Represents a week template name
class WeekTemplateNameModel implements Model {
  /// Default Constructor
  WeekTemplateNameModel({this.name, this.id});

  /// Construct from JSON
  WeekTemplateNameModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw const FormatException(
          '[WeekTemplateNameModel]: Cannot initialize from null');
    }

    name = json['name'];
    id = json['templateId'];
  }

  /// Name of the template
  String name;

  /// The template's ID
  int id;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'name': name, 'templateId': id};
  }

  /// getter for repository
  static IOfflineRepository<Model> offline() {
    return OfflineRepository((WeekTemplateNameModel).toString());
  }

}
