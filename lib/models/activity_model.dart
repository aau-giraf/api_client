import 'package:api_client/models/model.dart';
import 'package:api_client/models/pictogram_model.dart';
import 'package:api_client/models/timer_model.dart';
import 'package:meta/meta.dart';
import 'enums/activity_state_enum.dart';

/// The model for the activity in the api client.
class ActivityModel implements Model {
  /// Constructor for Activity
  ActivityModel(
      {@required this.id,
      @required this.pictograms,
      @required this.order,
      @required this.state,
      @required this.isChoiceBoard,
      this.choiceBoardName,
      this.timer});

  /// Constructs the activityModel from json.
  ActivityModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw const FormatException(
          '[ActivityModel]: Cannot initialize from null');
    }

    id = json['id'];
    pictograms = <PictogramModel>[];
    for (Map<String, dynamic> pictogram in json['pictograms']) {
      pictograms.add(PictogramModel.fromJson(pictogram));
    }
    order = json['order'];
    state = ActivityState.values[(json['state']) - 1];
    isChoiceBoard = json['isChoiceBoard'];
    choiceBoardName = json['choiceBoardName'];
    if (json['timer'] != null) {
      timer = TimerModel.fromJson(json['timer']);
    }
  }

  /// Constructer from json for the offlineDb
  ActivityModel.fromDatabase(
      Map<String, dynamic> json, this.timer, this.pictograms) {
    if (json == null) {
      throw const FormatException(
          '[ActivityModel]: Cannot initialize from null');
    }
    id = json['Key'];
    order = json['Order'];
    int stateIndex;
    if (json['State'] is int) {
      stateIndex = json['State'];
    } else {
      final String stateString = json['State'];
      stateIndex = int.tryParse(stateString);
    }
    state = ActivityState.values[stateIndex];
    isChoiceBoard = json['IsChoiceBoard'] == 1;
  }

  /// The ID of the activity.
  int id;

  /// The pictogram for the activity.
  List<PictogramModel> pictograms;

  /// The order that the activity will appear on in a weekschedule. If two has
  /// same order it is a choice
  int order;

  /// The current ActivityState
  ActivityState state;

  /// This is used in the WeekPlanner app by the frontend groups and should
  /// never be set from our side
  bool isChoiceBoard;

  /// name of the choiceboard
  String choiceBoardName;

  /// The timer for the activity
  TimerModel timer;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'pictograms': pictograms
          .map((PictogramModel pictogram) => pictogram.toJson())
          .toList(),
      'order': order,
      'state': state.index + 1,
      'isChoiceBoard': isChoiceBoard,
      'choiceBoardName': choiceBoardName,
      'timer': timer != null ? timer.toJson() : null
    };
  }
}
