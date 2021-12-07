import 'package:api_client/models/model.dart';
import 'package:api_client/models/pictogram_model.dart';
import 'package:api_client/models/week_base_model.dart';
import 'package:api_client/models/weekday_model.dart';

/// Represents a week
class WeekModel extends WeekBaseModel implements Model {
  /// Default constructor
  WeekModel({
    PictogramModel thumbnail,
    String name,
    List<WeekdayModel> days,
    this.weekYear,
    this.weekNumber,
  }) : super(thumbnail: thumbnail, name: name, days: days);

  /// Construct from JSON
  WeekModel.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    weekYear = json['weekYear'];
    weekNumber = json['weekNumber'];
  }

  /// Construct from offline database JSON
  WeekModel.fromDatabase(Map<String, dynamic> json) : super.fromDatabase(json) {
    weekYear = json['weekYear'];
    weekNumber = json['weekNumber'];
  }

  /// The year the week lies in
  int weekYear;

  /// The week number
  int weekNumber;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> response = <String, dynamic>{
      'weekYear': weekYear,
      'weekNumber': weekNumber,
      'name': name,
    };

    // We have to take into account that this object
    // is used in two different ways, one with thumbnail
    // and another without thumbnail.
    if (thumbnail != null) {
      response['thumbnail'] = thumbnail.toJson();
    }

    // We have to take into account that this object
    // is used in two different ways, one with days
    // and another without days.
    if (days != null) {
      response['days'] =
          days.map((WeekdayModel element) => element.toJson()).toList();
    }

    return response;
  }
}
