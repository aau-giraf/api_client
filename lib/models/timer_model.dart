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
    if (json == null) {
      throw const FormatException(
          '[TimerModel]: Cannot initialize from null');
    }
      startTime = json['startTimer'];
      progress = json['progress'];
      fullLength = json['fullLength'];
      paused = json['paused'];

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
      'startTimer': startTime.toIso8601String() ?? 'null',
      'progress': progress ?? 'null',
      'fullLength': fullLength ?? 'null',
      'paused': paused ?? 'null'
    };
  }
}