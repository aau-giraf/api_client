import 'dart:async';

import 'package:api_client/api/api_exception.dart';
import 'package:api_client/http/http.dart';
import 'package:api_client/offline_database/offline_db_handler.dart';
import 'package:flutter/material.dart';
import 'package:api_client/models/giraf_user_model.dart';
import 'package:api_client/models/settings_model.dart';
import 'package:api_client/models/displayname_model.dart';

import 'connectivity_api.dart';

/// User endpoints
class UserApi {
  /// Default constructor
  UserApi(this._http, this._connectivity);

  final Http _http;
  final ConnectivityApi _connectivity;

  /// Find information about the currently authenticated user.
  Stream<GirafUserModel> me() => _connectivity.handle(
      () => _http
          .get('/')
          .map((Response res) => GirafUserModel.fromJson(res.json['data']))
          .first,
      () => OfflineDbHandler.instance.getMe()
  );

  /// Find information on the user with the given ID
  ///
  /// [id] ID of the user
  Stream<GirafUserModel> get(String id) => _connectivity.handle(
      () {
        final Future<GirafUserModel> user = _http
          .get('/$id')
          .map((Response res) => GirafUserModel.fromJson(res.json['data']))
          .first;

        user.then((GirafUserModel user) =>
            OfflineDbHandler.instance.updateUser(user));

        return user;
      },
      () => OfflineDbHandler.instance.getUser(id)
  );

  /// Get the role of the user with the username inputted
  ///
  /// [username] Username of the user
  Stream<int> role(String username) => _connectivity.handle(
      () => _http
              .get('/$username/role')
              .map<int>((Response res) => res.json['data']).first,
      () => OfflineDbHandler.instance.getUserRole(username)
  );

  /// Updates the user with the information in GirafUserModel
  ///
  /// [user] The updated user
  Stream<GirafUserModel> update(GirafUserModel user) => _connectivity.handle(
      () => _http
              .put('/${user.id}', user.toJson())
              .map((Response res) => GirafUserModel
                .fromJson(res.json['data'])).first,
      () => OfflineDbHandler.instance.updateUser(user)
  );

  /// Get user-settings for the user with the specified Id
  ///
  /// [id] Identifier of the GirafUser to get settings for
  Stream<SettingsModel> getSettings(String id) => _connectivity.handle(
      () {
        final Future<SettingsModel> settings = _http
            .get('/$id/settings')
            .map((Response res) => SettingsModel
              .fromJson(res.json['data'])).first;

        // This will save the settings and update the settingsId for the user
        settings.then((SettingsModel settings) =>
        // TODO(MathiasNielsen): Only insert if the settings does not exist DB
            OfflineDbHandler.instance.insertUserSettings(id, settings)
        );

        return settings;
      },
      () => OfflineDbHandler.instance.getUserSettings(id)
  );

  /// Updates the user settings for the user with the provided id
  ///
  /// [id] Identifier of the GirafUser to update settings for
  /// [settings] reference to a Settings containing the new settings
  Stream<SettingsModel> updateSettings(String id, SettingsModel settings) =>
      _connectivity.handle(
          () {
            Future<SettingsModel> result = _http
                .put('/$id/settings', settings.toJson())
                .map((Response res) => SettingsModel
                .fromJson(res.json['data'])).first;

            OfflineDbHandler.instance.updateUserSettings(id, settings);

            return result;
          },
          () => OfflineDbHandler.instance.updateUserSettings(id, settings)
  );

  /// Deletes the user icon for a given user
  ///
  /// [id] Identifier for the user to which the icon should be deleted
  Stream<bool> deleteIcon(String id) =>
      _connectivity.handle(
          () {
            final Future<bool> result = _http
                .delete('/$id/icon')
                .map((Response res) => res.statusCode() == 200).first;

            OfflineDbHandler.instance.deleteUserIcon(id);
            return result;
          },
          () => OfflineDbHandler.instance.deleteUserIcon(id)
  );



  /// Gets the raw user icon for a given user
  ///
  /// [id] Identifier of the GirafUser to get icon for
  Stream<Image> getIcon(String id) =>
      _connectivity.handle(
          () {
            final Future<Image> result = _http
                .get('/$id/icon/raw')
                .map((Response res) =>
                  Image.memory(res.response.bodyBytes)).first;
            result.then((Image icon) =>
                OfflineDbHandler.instance.insertUserIcon(id,icon));

            return result;
          },
          () => OfflineDbHandler.instance.getUserIcon(id)
  );


  /// NYI
  Stream<bool> updateIcon() {
    // TODO(boginw): implement this
    return null;
  }

  /// Gets the citizens of the user with the provided id. The provided user must
  /// be a guardian
  ///
  /// [id] Identifier of the GirafUser to get citizens for
  Stream<List<DisplayNameModel>> getCitizens(String id)
      => _connectivity.handle(
          () {
            final Future<List<DisplayNameModel>> result = _http
                .get('/$id/citizens')
                .map((Response res) =>
                List<Map<String, dynamic>>.from(res.json['data'])
                    .map((Map<String, dynamic> val) =>
                    DisplayNameModel.fromJson(val))
                    .toList()).first;
            result.then((List<DisplayNameModel> citizens) {
              for(DisplayNameModel citizen in citizens) {
                  OfflineDbHandler.instance
                    .addCitizenToGuardian(id, citizen.id);
              }
            });
            return result;
          },
          () => OfflineDbHandler.instance.getCitizens(id)
  );


  /// Gets the guardians for the specific citizen corresponding to the
  /// provided id.
  ///
  /// [id] Identifier for the citizen to get guardians for
  Stream<List<DisplayNameModel>> getGuardians(String id) =>
      _connectivity.handle(
          () => _http
            .get('/$id/guardians')
            .map((Response res) =>
              List<Map<String, dynamic>>.from(res.json['data'])
                .map((Map<String, dynamic> val) =>
                  DisplayNameModel.fromJson(val))
                .toList()).first,
          () => OfflineDbHandler.instance.getGuardians(id)
  );


  /// Adds relation between the authenticated user (guardian) and an
  /// existing citizen.
  ///
  /// [guardianId] The guardian
  /// [citizenId] The citizen to be added to the guardian
  Stream<bool> addCitizenToGuardian(String guardianId, String citizenId) =>
      _connectivity.handle(
          () {
            final Future<bool> result = _http
              .post('/$guardianId/citizens/$citizenId')
              .map((Response res) => res.statusCode() == 200).first;
            OfflineDbHandler.instance
              .addCitizenToGuardian(guardianId, citizenId);
            return result;
          },
          () => OfflineDbHandler.instance
                  .addCitizenToGuardian(guardianId, citizenId)
  );
}
