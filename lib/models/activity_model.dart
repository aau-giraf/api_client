import 'package:api_client/models/enums/activity_state_enum.dart';
import 'package:api_client/models/model.dart';
import 'package:api_client/models/pictogram_model.dart';
import 'package:meta/meta.dart';

class ActivityModel implements Model {
  ActivityModel({
    @required this.id,
    @required this.pictogram,
    @required this.order,
    @required this.state,
    @required this.isChoiceBoard,
  });

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
  }

  int id;

  PictogramModel pictogram;

  /// The order that the activity will appear on in a weekschedule. If two has
  /// same order it is a choice
  int order;

  /// The current ActivityState
  ActivityState state;

  /// This is used in the WeekPlanner app by the frontend groups and should
  /// never be set from our side
  bool isChoiceBoard;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'pictogram': pictogram.toJson(),
      'order': order,
      'state': state.index + 1,
      'isChoiceBoard': isChoiceBoard,
    };
  }
}
