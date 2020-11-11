import 'package:api_client/models/model.dart';
import 'package:api_client/models/pictogram_model.dart';
import 'package:api_client/models/week_base_model.dart';
import 'package:api_client/models/weekday_model.dart';

/// Represents the week template
class WeekTemplateModel extends WeekBaseModel implements Model {
  /// Default constructor
  WeekTemplateModel(
      {PictogramModel thumbnail,
      String name,
      List<WeekdayModel> days,
      this.departmentKey,
      this.id})
      : super(thumbnail: thumbnail, name: name, days: days);

  /// Construct from JSON
  WeekTemplateModel.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    if (json == null) {
      throw const FormatException(
          '[WeekTemplateModel]: Cannot initialize from null');
    }

    departmentKey = json['departmentKey'];
    id = json['id'];
  }

  /// Construct from offline database JSON
  WeekTemplateModel.fromDatabase(Map<String, dynamic> json)
      : super.fromDatabase(json) {
    if (json == null) {
      throw const FormatException(
          '[WeekTemplateModel]: Cannot initialize from null');
    }
    departmentKey = json['Department'];
    id = json['id'];
  }

  /// Key for the Department
  int departmentKey;

  /// This Week template's ID
  int id;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'departmentKey': departmentKey,
      'id': id,
      'thumbnail': thumbnail.toJson(),
      'name': name,
      'days': days.map((WeekdayModel element) => element.toJson()).toList()
    };
  }
}
