import 'package:api_client/models/model.dart';
import 'package:api_client/models/enums/weekday_enum.dart';
import 'package:api_client/offline_repository/repository.dart';
import 'package:api_client/offline_repository/repository_interface.dart';

/// Represents the weekday color
class WeekdayColorModel implements Model {
  /// Default constructor
  WeekdayColorModel({this.hexColor, this.day});

  /// Construct from JSON
  WeekdayColorModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw const FormatException(
          '[WeekdayColorModel]: Cannot initialize from null');
    }

    hexColor = json['hexColor'];
    day = Weekday.values[json['day'] - 1];
  }

  /// The color of the day in Hex format
  String hexColor;

  /// The day of the week
  Weekday day;

  @override
  /// Offline id
  int offlineId;

  @override
  /// Get offline id
  int getOfflineId() {
    return offlineId;
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'hexColor': hexColor, 'day': day.index + 1};
  }

  /// getter for repository
  static IOfflineRepository<Model> offline() {
    return OfflineRepository((WeekdayColorModel).toString());
  }

}
