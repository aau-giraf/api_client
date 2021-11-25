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
  Stream<GirafUserModel> me() {
    return _http
        .get('/')
        .map((Response res) => GirafUserModel.fromJson(res.json['data']));
  }

  /// Find information on the user with the given ID
  ///
  /// [id] ID of the user
  Stream<GirafUserModel> get(String id) {
    return _http
        .get('/$id')
        .map((Response res) => GirafUserModel.fromJson(res.json['data']));
  }

  ///Get the role of the user with the username inputted
  ///
  /// [username] Username of the user
  Stream<int> role(String username) {
    final Completer<int> completer = Completer<int>();

    print("Getting role");
    _connectivity.check().then((bool connected) {
      connected = false;
      if (connected) {
        completer.complete(_http
            .get('/$username/role')
            .map<int>((Response res) => res.json['data']).first);
      }
      else {
        print("hej");
        completer.complete(1);
      }
    });

    /*_connectivity.check().then((bool connected) {
      if (connected) {
        completer.complete(_http
            .get('/$username/role')
            .map<int>((Response res) => res.json['data']).first);
      }
      else {
        completer.complete(OfflineDbHandler.instance.getUserRole(username));
      }
    });*/

    return Stream<int>.fromFuture(completer.future);
  }

  /// Updates the user with the information in GirafUserModel
  ///
  /// [user] The updated user
  Stream<GirafUserModel> update(GirafUserModel user) {
    return _http
        .put('/${user.id}', user.toJson())
        .map((Response res) => GirafUserModel.fromJson(res.json['data']));
  }

  /// Get user-settings for the user with the specified Id
  ///
  /// [id] Identifier of the GirafUser to get settings for
  Stream<SettingsModel> getSettings(String id) {
    return _http.get('/$id/settings').map((Response res) {
      if (res.success() == false) {
        throw ApiException(res);
      }
      return SettingsModel.fromJson(res.json['data']);
    });
  }

  /// Updates the user settings for the user with the provided id
  ///
  /// [id] Identifier of the GirafUser to update settings for
  /// [settings] reference to a Settings containing the new settings
  Stream<SettingsModel> updateSettings(String id, SettingsModel settings) {
    return _http.put('/$id/settings', settings.toJson()).map((Response res) {
      if (res.success() == false) {
        throw ApiException(res);
      }
      return SettingsModel.fromJson(res.json['data']);
    });
  }

  /// Deletes the user icon for a given user
  ///
  /// [id] Identifier fo the user to which the icon should be deleted
  Stream<bool> deleteIcon(String id) {
    return _http
        .delete('/$id/icon')
        .map((Response res) => res.statusCode() == 200);
  }

  /// Gets the raw user icon for a given user
  ///
  /// [id] Identifier of the GirafUser to get icon for
  Stream<Image> getIcon(String id) {
    return _http.get('/$id/icon/raw').map((Response res) {
      return Image.memory(res.response.bodyBytes);
    });
  }

  /// NYI
  Stream<bool> updateIcon() {
    // TODO(boginw): implement this
    return null;
  }

  /// Gets the citizens of the user with the provided id. The provided user must
  /// be a guardian
  ///
  /// [id] Identifier of the GirafUser to get citizens for
  Stream<List<DisplayNameModel>> getCitizens(String id) {
    return _http.get('/$id/citizens').map((Response res) {
      if (res.json['data'] is List) {
        return List<Map<String, dynamic>>.from(res.json['data'])
            .map((Map<String, dynamic> val) => DisplayNameModel.fromJson(val))
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
  Stream<List<DisplayNameModel>> getGuardians(String id) {
    return _http.get('/$id/guardians').map((Response res) {
      if (res.json['data'] is List) {
        return List<Map<String, dynamic>>.from(res.json['data'])
            .map((Map<String, dynamic> val) => DisplayNameModel.fromJson(val))
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
  Stream<bool> addCitizenToGuardian(String guardianId, String citizenId) {
    return _http
        .post('/$guardianId/citizens/$citizenId')
        .map((Response res) => res.statusCode() == 200);
  }
}
