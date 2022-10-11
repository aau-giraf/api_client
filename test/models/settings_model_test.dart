import 'package:flutter_test/flutter_test.dart';
import 'package:api_client/models/enums/giraf_theme_enum.dart';
import 'package:api_client/models/enums/cancel_mark_enum.dart';
import 'package:api_client/models/enums/complete_mark_enum.dart';
import 'package:api_client/models/enums/default_timer_enum.dart';
import 'package:api_client/models/enums/orientation_enum.dart';
import 'package:api_client/models/settings_model.dart';

void main() {
  final Map<String, dynamic> response = <String, dynamic>{
    'Orientation': 1,
    'CompleteMark': 2,
    'CancelMark': 2,
    'DefaultTimer': 2,
    'TimerSeconds': 900,
    'ActivitiesCount': null,
    'Theme': 1,
    'NrOfDaysToDisplay': 7,
    'LockTimerControl': false,
    'GreyScale': false,
    'PictogramText' : false,
    'WeekDayColors': <dynamic>[
      <String, dynamic>{'hexColor': '#067700', 'day': 1},
      <String, dynamic>{'hexColor': '#8c1086', 'day': 2},
      <String, dynamic>{'hexColor': '#ff7f00', 'day': 3},
      <String, dynamic>{'hexColor': '#0017ff', 'day': 4},
      <String, dynamic>{'hexColor': '#ffdd00', 'day': 5},
      <String, dynamic>{'hexColor': '#ff0102', 'day': 6},
      <String, dynamic>{'hexColor': '#ffffff', 'day': 7}
    ]
  };

  test('Can instantiate from JSON', () {
    final SettingsModel settings = SettingsModel.fromJson(response);

    expect(
        settings.orientation, Orientation.values[response['Orientation'] - 1]);
    expect(settings.completeMark,
        CompleteMark.values[response['CompleteMark'] - 1]);
    expect(settings.cancelMark, CancelMark.values[response['CancelMark'] - 1]);
    expect(settings.defaultTimer,
        DefaultTimer.values[response['DefaultTimer'] - 1]);
    expect(settings.timerSeconds, response['TimerSeconds']);
    expect(settings.activitiesCount, response['ActivitiesCount']);
    expect(settings.theme, GirafTheme.values[response['Theme'] - 1]);
    expect(settings.lockTimerControl, false);
    expect(settings.pictogramText, false);
    expect(settings.greyscale, false);
    expect(settings.weekDayColors.length, 7);
    expect(settings.weekDayColors[0].toJson(), response['WeekDayColors'][0]);
    expect(settings.weekDayColors[1].toJson(), response['WeekDayColors'][1]);
    expect(settings.weekDayColors[2].toJson(), response['WeekDayColors'][2]);
    expect(settings.weekDayColors[3].toJson(), response['WeekDayColors'][3]);
    expect(settings.weekDayColors[4].toJson(), response['WeekDayColors'][4]);
    expect(settings.weekDayColors[5].toJson(), response['WeekDayColors'][5]);
    expect(settings.weekDayColors[6].toJson(), response['WeekDayColors'][6]);
  });

  test('Will throw exception when JSON is null', () {
    expect(() => SettingsModel.fromJson(null), throwsFormatException);
  });

  test('Can serialize into JSON', () {
    final SettingsModel settings = SettingsModel.fromJson(response);

    expect(settings.toJson(), response);
  });
}