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

/// A model used to store settings values
class SettingsModel implements Model {
  /// Constructor
  SettingsModel(
      {@required this.orientation,
        @required this.completeMark,
        @required this.cancelMark,
        @required this.defaultTimer,
        this.timerSeconds,
        this.activitiesCount,
        @required this.theme,
        this.nrOfDaysToDisplay,
        this.lockTimerControl,
        this.pictogramText,
        this.greyscale,
        this.weekDayColors});

  /// Another constructor used to create from json.
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
    lockTimerControl = json['lockTimerControl'];
    pictogramText = json['pictogramText'];
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

  /// Defines if the user can stop/pause/restart a timer once started
  bool lockTimerControl;

  /// Flag for indicating whether or not greyscale is enabled
  bool greyscale;

  /// Defines if text should be shown alongside the pictograms in the weekplan
  bool pictogramText;

  /// List of weekday colors shown in the weekplan
  List<WeekdayColorModel> weekDayColors;

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
      'orientation': orientation.index + 1,
      'completeMark': completeMark.index + 1,
      'cancelMark': cancelMark.index + 1,
      'defaultTimer': defaultTimer.index + 1,
      'timerSeconds': timerSeconds,
      'activitiesCount': activitiesCount,
      'theme': theme.index + 1,
      'nrOfDaysToDisplay': nrOfDaysToDisplay,
      'lockTimerControl' : lockTimerControl,
      'greyScale': greyscale,
      'pictogramText' : pictogramText,
      'weekDayColors':
      weekDayColors?.map((WeekdayColorModel e) => e.toJson())?.toList()
    };
  }

  /// getter for repository
  static IOfflineRepository<Model> offline() {
    return OfflineRepository((SettingsModel).toString());
  }
}
