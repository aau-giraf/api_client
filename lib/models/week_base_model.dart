import 'package:api_client/models/pictogram_model.dart';
import 'package:api_client/models/weekday_model.dart';

abstract class WeekBaseModel {
  WeekBaseModel({this.thumbnail, this.name, this.days});

  WeekBaseModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw const FormatException(
          '[WeekBaseModel]: Cannot initialize from null');
    }

    name = json['name'];

    // WeekModel sometimes don't have a thumbnail
    if (json['thumbnail'] != null) {
      thumbnail = PictogramModel.fromJson(json['thumbnail']);
    }

    // WeekModel sometimes dont have days
    if (json['days'] != null && json['days'] is List) {
      days = List<Map<String, dynamic>>.from(json['days'])
          .map((Map<String, dynamic> element) => WeekdayModel.fromJson(element))
          .toList();
    }
  }

  PictogramModel thumbnail;

  String name;

  List<WeekdayModel> days;
}
