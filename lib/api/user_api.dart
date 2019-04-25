import 'package:api_client/http/http.dart';
import 'package:api_client/models/giraf_user_model.dart';
import 'package:api_client/models/settings_model.dart';
import 'package:api_client/models/username_model.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

/// User endpoints
class UserApi {
  /// Default constructor
  UserApi(this._http);

  final Http _http;

  /// Find information about the currently authenticated user.
  Observable<GirafUserModel> me() {
    return _http
        .get('/')
        .map((Response res) => GirafUserModel.fromJson(res.json['data']));
  }

  /// Find information on the user with the given ID
  ///
  /// [id] ID of the user
  Observable<GirafUserModel> get(String id) {
    return _http
        .get('/$id')
        .map((Response res) => GirafUserModel.fromJson(res.json['data']));
  }

  /// Updates the user with the information in GirafUserModel
  ///
  /// [user] The updated user
  Observable<GirafUserModel> update(GirafUserModel user) {
    return _http
        .put('/${user.id}', user.toJson())
        .map((Response res) => GirafUserModel.fromJson(res.json['data']));
  }

  /// Get user-settings for the user with the specified Id
  ///
  /// [id] Identifier of the GirafUser to get settings for
  Observable<SettingsModel> getSettings(String id) {
    return _http
        .get('/$id/settings')
        .map((Response res) => SettingsModel.fromJson(res.json['data']));
  }

  /// Updates the user settings for the user with the provided id
  ///
  /// [id] Identifier of the GirafUser to update settings for
  /// [settings] reference to a Settings containing the new settings
  Observable<SettingsModel> updateSettings(String id, SettingsModel settings) {
    return _http
        .put('/$id/settings', settings.toJson())
        .map((Response res) => SettingsModel.fromJson(res.json['data']));
  }

  /// Deletes the user icon for a given user
  ///
  /// [id] Identifier fo the user to which the icon should be deleted
  Observable<bool> deleteIcon(String id) {
    return _http.delete('/$id/icon').map((Response res) => res.json['success']);
  }

  /// Gets the raw user icon for a given user
  ///
  /// [id] Identifier of the GirafUser to get icon for
  Observable<Image> getIcon(String id) {
    return _http.get('/$id/icon/raw').map((Response res) {
      return Image.memory(res.response.bodyBytes);
    });
  }
  
  Observable<bool> updateIcon() {
    // TODO(boginw): implement this
    return null;
  }

  /// Gets the citizens of the user with the provided id. The provided user must
  /// be a guardian
  ///
  /// [id] Identifier of the GirafUser to get citizens for
  Observable<List<UsernameModel>> getCitizens(String id) {
    return _http.get('/$id/citizens').map((Response res) {
      if (res.json['data'] is List) {
        return List<Map<String, dynamic>>.from(res.json['data'])
            .map((Map<String, dynamic> val) => UsernameModel.fromJson(val))
            .toList();
      } else {
        return null;
      }
    });
  }

  /// Gets the guardians for the specific citizen corresponding to the
  /// provided id.
  ///
  /// [id] Identifier for the citizen to get guardians for
  Observable<List<UsernameModel>> getGuardians(String id) {
    return _http.get('/$id/guardians').map((Response res) {
      if (res.json['data'] is List) {
        return List<Map<String, dynamic>>.from(res.json['data'])
            .map((Map<String, dynamic> val) => UsernameModel.fromJson(val))
            .toList();
      } else {
        return null;
      }
    });
  }

  /// Adds relation between the authenticated user (guardian) and an
  /// existing citizen.
  ///
  /// [guardianId] The guardian
  /// [citizenId] The citizen to be added to the guardian
  Observable<bool> addCitizenToGuardian(String guardianId, String citizenId) {
    return _http
        .post('/$guardianId/citizens/$citizenId')
        .map((Response res) => res.json['success']);
  }
}
