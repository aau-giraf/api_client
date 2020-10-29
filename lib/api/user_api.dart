import 'package:api_client/api/api_exception.dart';
import 'package:api_client/http/http.dart';
import 'package:api_client/models/enums/cancel_mark_enum.dart';
import 'package:api_client/models/enums/complete_mark_enum.dart';
import 'package:api_client/models/enums/default_timer_enum.dart';
import 'package:api_client/models/enums/giraf_theme_enum.dart';
import 'package:api_client/models/enums/weekday_enum.dart';
import 'package:api_client/models/weekday_color_model.dart';
import 'package:api_client/offline_database/offline_db_handler.dart';
import 'package:flutter/material.dart';
import 'package:api_client/models/giraf_user_model.dart';
import 'package:api_client/models/settings_model.dart';
import 'package:api_client/models/displayname_model.dart';
import 'package:api_client/models/enums/orientation_enum.dart' as orientation;

/// User endpoints
class UserApi {
  /// Default constructor
  UserApi(this._http);

  final Http _http;

  /// Find information about the currently authenticated user.
  Stream<GirafUserModel> me() {
    if (OfflineDbHandler.instance.getMe() == null) {
      return _http.get('/').map((Response res) {
        final GirafUserModel currentMe =
            GirafUserModel.fromJson(res.json['data']);
        OfflineDbHandler.instance.setMe(currentMe);
        return currentMe;
      });
    } else {
      Stream<GirafUserModel>.fromFuture(
          Future<GirafUserModel>.value(OfflineDbHandler.instance.getMe()));
    }
  }

  /// Find information on the user with the given ID
  ///
  /// [id] ID of the user
  Stream<GirafUserModel> get(String id) {
    return _http.get('/$id').asyncMap((Response res) {
      if (res.success()) {
        return GirafUserModel.fromJson(res.json['data']);
      } else {
        return OfflineDbHandler.instance.getUser(id);
      }
    });
  }

  /// Updates the user with the information in GirafUserModel
  ///
  /// [user] The updated user
  Stream<GirafUserModel> update(GirafUserModel user) {
    return _http.put('/${user.id}', user.toJson()).asyncMap((Response res) {
      if (res.success()) {
        OfflineDbHandler.instance.updateUser(user);
        return GirafUserModel.fromJson(res.json['data']);
      } else {
        return OfflineDbHandler.instance.updateUser(user);
      }
    });
  }

  /// Get user-settings for the user with the specified Id
  ///
  /// [id] Identifier of the GirafUser to get settings for
  Stream<SettingsModel> getSettings(String id) {
    return _http.get('/$id/settings').map((Response res) {
      if (res.success() == false) {
        return SettingsModel(
            theme: GirafTheme.GirafYellow,
            cancelMark: CancelMark.Removed,
            completeMark: CompleteMark.Removed,
            defaultTimer: DefaultTimer.Numeric,
            orientation: orientation.Orientation.Portrait,
            timerSeconds: 0,
            activitiesCount: 0,
            nrOfDaysToDisplay: 7,
            lockTimerControl: true,
            pictogramText: true,
            greyscale: false,
            weekDayColors: [
              WeekdayColorModel(hexColor: '#08a045', day: Weekday.Monday),
              WeekdayColorModel(hexColor: '#540d6e', day: Weekday.Tuesday),
              WeekdayColorModel(hexColor: '#f77f00', day: Weekday.Wednesday),
              WeekdayColorModel(hexColor: '#004777', day: Weekday.Thursday),
              WeekdayColorModel(hexColor: '#f9c80e', day: Weekday.Friday),
              WeekdayColorModel(hexColor: '#db2b39', day: Weekday.Saturday),
              WeekdayColorModel(hexColor: '#ffffff', day: Weekday.Sunday),
            ]);
      } else {
        return SettingsModel.fromJson(res.json['data']);
      }
    });
  }

  /// Updates the user settings for the user with the provided id
  ///
  /// [id] Identifier of the GirafUser to update settings for
  /// [settings] reference to a Settings containing the new settings
  Stream<SettingsModel> updateSettings(String id, SettingsModel settings) {
    return _http
        .put('/$id/settings', settings.toJson())
        .asyncMap((Response res) {
      if (res.success()) {
        OfflineDbHandler.instance.updateUserSettings(id, settings);
        if (res.success() == false) {
          throw ApiException(res);
        }
        return SettingsModel.fromJson(res.json['data']);
      } else {
        OfflineDbHandler.instance.updateUserSettings(id, settings);
      }
    });
  }

  /// Deletes the user icon for a given user
  ///
  /// [id] Identifier fo the user to which the icon should be deleted
  Stream<bool> deleteIcon(String id) {
    return _http.delete('/$id/icon').asyncMap((Response res) {
      if (res.statusCode() == 200) {
        OfflineDbHandler.instance.deleteUserIcon(id);
        return true;
      } else {
        return OfflineDbHandler.instance.deleteUserIcon(id);
      }
    });
  }

  /// Gets the raw user icon for a given user
  ///
  /// [id] Identifier of the GirafUser to get icon for
  Stream<Image> getIcon(String id) {
    return _http.get('/$id/icon/raw').asyncMap((Response res) {
      if (res.success()) {
        OfflineDbHandler.instance.getUserIcon(id);
        return Image.memory(res.response.bodyBytes);
      } else {
        return OfflineDbHandler.instance.getUserIcon(id);
      }
    });
  }

  Stream<bool> updateIcon() {
    // TODO(boginw): implement this
    return null;
  }

  /// Gets the citizens of the user with the provided id. The provided user must
  /// be a guardian
  ///
  /// [id] Identifier of the GirafUser to get citizens for
  Stream<List<DisplayNameModel>> getCitizens(String id) {
    return _http.get('/$id/citizens').asyncMap((Response res) {
      if (res.success()) {
        if (res.json['data'] is List) {
          return List<Map<String, dynamic>>.from(res.json['data'])
              .map((Map<String, dynamic> val) => DisplayNameModel.fromJson(val))
              .toList();
        } else {
          return OfflineDbHandler.instance.getCitizens(id);
        }
      }
    });
  }

  /// Gets the guardians for the specific citizen corresponding to the
  /// provided id.
  ///
  /// [id] Identifier for the citizen to get guardians for
  Stream<List<DisplayNameModel>> getGuardians(String id) {
    return _http.get('/$id/guardians').asyncMap((Response res) {
      if (res.success()) {
        if (res.json['data'] is List) {
          return List<Map<String, dynamic>>.from(res.json['data'])
              .map((Map<String, dynamic> val) => DisplayNameModel.fromJson(val))
              .toList();
        } else {
          return OfflineDbHandler.instance.getGuardians(id);
        }
      }
    });
  }

  /// Adds relation between the authenticated user (guardian) and an
  /// existing citizen.
  ///
  /// [guardianId] The guardian
  /// [citizenId] The citizen to be added to the guardian
  Stream<bool> addCitizenToGuardian(String guardianId, String citizenId) {
    return _http
        .post('/$guardianId/citizens/$citizenId')
        .asyncMap((Response res) {
      if (res.statusCode() == 200) {
        OfflineDbHandler.instance.addCitizenToGuardian('guardianId', citizenId);
        return true;
      } else {
        return OfflineDbHandler.instance
            .addCitizenToGuardian(guardianId, citizenId);
      }
    });
  }

  Future<void> hydrateOfflineDbUser(GirafUserModel getUser, String id) async {}
}
