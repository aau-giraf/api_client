import 'package:api_client/models/model.dart';
import 'package:meta/meta.dart';

/// Represents a timer for an activity
class TimerModel implements Model {
  /// Constructor for timer
  TimerModel({
    @required this.startTime,
    @required this.progress,
    @required this.fullLength,
    @required this.paused,
  });

  /// Constructor for the timer from json.
  TimerModel.fromJson(Map<String, dynamic> json) {
    if (json == null){
      throw const FormatException(
          '[ActivityModel]: Cannot initialize from null');
      startTime = null;
      progress = null;
      fullLength = null;
      paused = null;
    } else {
      startTime = json['startTimer'];
      progress = json['prgress'];
      fullLength = json['fullLength'];
      paused = json['paused'];
    }
  }

  /// The time for when the timer started.
  DateTime startTime;

  /// The progress of the timer
  int progress;

  /// The full timer length
  int fullLength;

  /// Bool if the timer is paused or not
  bool paused;


  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'startTimer': startTime != null ? startTime : 'null',
      'progress': progress != null ? progress : 'null',
      'fullLength': fullLength != null ? fullLength : 'null',
      'paused': paused != null ? paused : 'null'
    };
  }
}