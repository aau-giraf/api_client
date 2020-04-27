import 'package:api_client/offline_repository/repository.dart';
import 'package:api_client/offline_repository/repository_interface.dart';
import 'package:meta/meta.dart';
import 'package:api_client/models/activity_model.dart';
import 'package:api_client/models/model.dart';
import 'package:api_client/models/enums/weekday_enum.dart';

/// Represents the Weekday
class WeekdayModel implements Model {
  /// Default constructor
  WeekdayModel({@required this.day, @required this.activities});

  /// Construct from JSON
  WeekdayModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw const FormatException(
          '[WeekdayModel]: Cannot instantiate from null');
    }

    day = Weekday.values[json['day'] - 1];
    if (json['activities'] is List) {
      activities = List<Map<String, dynamic>>.from(json['activities'])
          .map((Map<String, dynamic> val) => ActivityModel.fromJson(val))
          .toList();
    } else {
      // TODO(boginw): throw appropriate error
    }
  }

  /// Day of the week
  Weekday day;

  /// List of activities for the day
  List<ActivityModel> activities;

  @override
  /// Offline id
  int offlineId;

  @override
  /// Get offline id
  int getOfflineId() {
    return offlineId;
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'day': day.index + 1,
        'activities':
            activities.map((ActivityModel val) => val.toJson()).toList(),
      };

  /// getter for repository
  static IOfflineRepository<Model> offline() {
    return OfflineRepository((WeekdayModel).toString());
  }

}
