import 'package:api_client/models/model.dart';
import 'package:api_client/models/pictogram_model.dart';
import 'package:api_client/models/timer_model.dart';
import 'package:api_client/offline_repository/repository.dart';
import 'package:api_client/offline_repository/repository_interface.dart';
import 'package:meta/meta.dart';
import 'enums/activity_state_enum.dart';

/// The model for the activity in the api client.
class ActivityModel implements Model {
  /// Constructor for Activity
  ActivityModel(
      {@required this.id,
      @required this.pictogram,
      @required this.order,
      @required this.state,
      @required this.isChoiceBoard,
      this.timer});

  /// Constructs the activityModel from json.
  ActivityModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw const FormatException(
          '[ActivityModel]: Cannot initialize from null');
    }

    id = json['id'];
    pictogram = PictogramModel.fromJson(json['pictogram']);
    order = json['order'];
    state = ActivityState.values[(json['state']) - 1];
    isChoiceBoard = json['isChoiceBoard'];

    if (json['timer'] != null) {
      timer = TimerModel.fromJson(json['timer']);
    }
  }

  /// The ID of the activity.
  int id;

  /// The pictogram for the activity.
  PictogramModel pictogram;

  /// The order that the activity will appear on in a weekschedule. If two has
  /// same order it is a choice
  int order;

  /// The current ActivityState
  ActivityState state;

  /// This is used in the WeekPlanner app by the frontend groups and should
  /// never be set from our side
  bool isChoiceBoard;

  /// The timer for the activity
  TimerModel timer;

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
    return <String, dynamic>{
      'id': id,
      'pictogram': pictogram.toJson(),
      'order': order,
      'state': state.index + 1,
      'isChoiceBoard': isChoiceBoard,
      'timer': timer != null ? timer.toJson() : null
    };
  }

  /// getter for repository
  static IOfflineRepository<Model> offline() {
    return OfflineRepository((ActivityModel).toString());
  }

}
