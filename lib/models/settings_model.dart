import 'package:api_client/offline_repository/repository.dart';
import 'package:api_client/offline_repository/repository_interface.dart';
import 'package:meta/meta.dart';
import 'package:api_client/models/enums/giraf_theme_enum.dart';
import 'package:api_client/models/enums/cancel_mark_enum.dart';
import 'package:api_client/models/enums/complete_mark_enum.dart';
import 'package:api_client/models/enums/default_timer_enum.dart';
import 'package:api_client/models/model.dart';
import 'package:api_client/models/enums/orientation_enum.dart';
import 'package:api_client/models/weekday_color_model.dart';

class SettingsModel implements Model {
  SettingsModel(
      {@required this.orientation,
      @required this.completeMark,
      @required this.cancelMark,
      @required this.defaultTimer,
      this.timerSeconds,
      this.activitiesCount,
      @required this.theme,
      this.nrOfDaysToDisplay,
      this.greyscale,
      this.weekDayColors});

  SettingsModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw const FormatException(
          '[SettingModel]: Cannot initialize from null');
    }

    orientation = Orientation.values[(json['orientation']) - 1];
    completeMark = CompleteMark.values[(json['completeMark']) - 1];
    cancelMark = CancelMark.values[(json['cancelMark']) - 1];
    defaultTimer = DefaultTimer.values[(json['defaultTimer']) - 1];
    timerSeconds = json['timerSeconds'];
    activitiesCount = json['activitiesCount'];
    theme = GirafTheme.values[(json['theme']) - 1];
    nrOfDaysToDisplay = json['nrOfDaysToDisplay'];
    greyscale = json['greyScale'];
    if (json['weekDayColors'] != null && json['weekDayColors'] is List) {
      weekDayColors = List<Map<String, dynamic>>.from(json['weekDayColors'])
          .map(
              (Map<String, dynamic> value) => WeekdayColorModel.fromJson(value))
          .toList();
    } else {
      // TODO(TobiasPalludan): Throw appropriate error.
    }
  }

  /// Preferred orientation of device/screen
  Orientation orientation;

  /// Preferred appearance of checked resources
  CompleteMark completeMark;

  /// Preferred appearance of cancelled resources
  CancelMark cancelMark;

  /// Preferred appearance of timer
  DefaultTimer defaultTimer;

  /// Number of seconds for timer
  int timerSeconds;

  /// Number of activities
  int activitiesCount;

  /// The preferred theme
  GirafTheme theme;

  /// defines the number of days to display for a user in a weekschedule
  int nrOfDaysToDisplay;

  /// Flag for indicating whether or not greyscale is enabled
  bool greyscale;

  List<WeekdayColorModel> weekDayColors;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'orientation': orientation.index + 1,
      'completeMark': completeMark.index + 1,
      'cancelMark': cancelMark.index + 1,
      'defaultTimer': defaultTimer.index + 1,
      'timerSeconds': timerSeconds,
      'activitiesCount': activitiesCount,
      'theme': theme.index + 1,
      'nrOfDaysToDisplay': nrOfDaysToDisplay,
      'greyScale': greyscale,
      'weekDayColors':
          weekDayColors?.map((WeekdayColorModel e) => e.toJson())?.toList()
    };
  }

  /// getter for repository
  static IOfflineRepository<Model> offline() {
    return OfflineRepository((SettingsModel).toString());
  }
}
