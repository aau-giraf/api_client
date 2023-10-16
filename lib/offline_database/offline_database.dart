import 'dart:typed_data';

import 'package:api_client/models/activity_model.dart';
import 'package:api_client/models/displayname_model.dart';
import 'package:api_client/models/enums/weekday_enum.dart';
import 'package:api_client/models/giraf_user_model.dart';
import 'package:api_client/models/pictogram_model.dart';
import 'package:api_client/models/settings_model.dart';
import 'package:api_client/models/week_model.dart';
import 'package:api_client/models/week_name_model.dart';
import 'package:api_client/models/week_template_model.dart';
import 'package:api_client/models/week_template_name_model.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

// ignore_for_file: missing_return

/// Interface for the offline db
class OfflineDb {
  /// Get the database, if it doesnt exist create it

  Future<Database?> get database async {}

  /// Return the directory where pictograms are saved
  Future<String?> get getPictogramDirectory async {}

  /// Initiate the database
  Future<Database?> initializeDatabase() async {}

  ///Creates all of the tables in the DB
  Future<void> createTables(Database db) async {}

  // offline to online functions
  /// Save failed online transactions
  /// [type] transaction type
  /// [baseUrl] baseUrl from the http
  /// [url] Url to send the transaction to
  /// [body] the json to send to the online database
  /// [tableAffected] NEEDS to be set when we try to create objects with public
  /// id's we need to have syncronized between the offline and online database
  Future<void> saveFailedTransactions(String type, String baseUrl, String url,
      {Map<String, dynamic>? body,
      String? tableAffected,
      String? tempId}) async {}

  /// Retry sending the failed changes to the online database
  Future<void> retryFailedTransactions() async {}

  /// Update the an Id in the database with a new one from the online database,
  /// once the online is done creating them. The [json] contains the key
  /// [table] is the table to be changed
  /// [tempId] is the id assigned when the object was created offline
  Future<void> updateIdInOfflineDb(
      Map<String, dynamic> json, String table, String tempId) async {}

  /// Replace the id of a User
  /// Should be called to replace the id given by this class with the one in the
  /// online database, such that they are synchonized
  Future<void> replaceTempIdUsers(String oldId, String newId) async {}

  /// Replace the id of a Pictogram
  /// Should be called to replace the id given by this class with the one in the
  /// online database, such that they are synchonized
  Future<void> replaceTempIdPictogram(String oldId, String newId) async {}

  /// Replace the id of a Pictogram
  /// Should be called to replace the id given by this class with the one in the
  /// online database, such that they are synchonized
  Future<void> replaceTempIdWeekTemplate(String oldId, String newId) async {}

  /// Remove a previously failed transaction from the
  /// offline database when it succeeds
  Future<void> removeFailedTransaction(
      Map<String, dynamic> transaction) async {}

  // Account API functions
  /// Returns [true] if [password] matches the password saved for [username]
  Future<bool?> login(String username, String password) async {}

  /// register an account for a user
  Future<GirafUserModel?> registerAccount(Map<String, dynamic> body) async {}

  /// Do not call this function without ensuring that the password is
  /// successfully changed online
  /// change a password of a user with id [id] to [newPassword]
  Future<bool?> changePassword(String id, String newPassword) async {}

  /// Delete a user from the offline database
  Future<bool?> deleteAccount(String id) async {}

  // Activity API functions
  /// Add an activity to DB
  Future<ActivityModel?> addActivity(
      ActivityModel activity,
      String userId,
      String weekplanName,
      int weekYear,
      int weekNumber,
      Weekday weekDay) async {}

  ///Update an [activity] from its id
  Future<ActivityModel?> updateActivity(
      ActivityModel activity, String userId) async {}

  ///Delete an activity with the id [activityId]
  Future<bool?> deleteActivity(int activityId, String userId) async {}

  // Pictogram API functions
  ///Get [pageSize] pictograms by adding all pictograms to a list
  ///and split them into lists with size [pageSize] and then choose
  ///list number [page]
  Future<List<PictogramModel>?> getAllPictograms(
      {String? query, required int page, required int pageSize}) async {}

  ///Get the pictogram with the id [id]
  Future<PictogramModel?> getPictogramID(int id) async {}

  ///Add a pictogram to the offline database
  Future<PictogramModel?> createPictogram(PictogramModel pictogram) async {}

  ///Update a given pictogram
  Future<PictogramModel?> updatePictogram(PictogramModel pictogram) async {}

  /// Delete a pictogram with the id [id]
  Future<bool?> deletePictogram(int id) async {}

  /// Update an image in the pictogram table
  Future<PictogramModel?> updateImageInPictogram(
      int id, Uint8List image) async {}

  /// Get an image from the local pictogram directory
  Future<Image?> getPictogramImage(int id) async {}

  // User API functions
  /// Return the me value
  GirafUserModel? getMe() {}

  /// Set the me value
  void setMe(GirafUserModel model) {}

  /// Get a user
  Future<GirafUserModel?> getUser(String id) async {}

  //Get User Id
  // ignore: public_member_api_docs
  Future<String?> getUserId(String userName) async {}

  /// Update a user based on [user.id] with the values from [user]
  Future<GirafUserModel?> updateUser(GirafUserModel user) async {}

  /// Get a the relevant settings for a user with the id: [id]
  Future<SettingsModel?> getUserSettings(String id) async {}

  /// Update the settings for a Girafuser with the id: [id]
  Future<SettingsModel?> updateUserSettings(
      String id, SettingsModel settings) async {}

  // /// Delete a users icon. as users do not have an icon,
  // /// this is not yet implemented
  // Future<bool?> deleteUserIcon(String id) {}

  // /// Get a users icon. as users do not have an icon,
  // /// this is not yet implemented
  // Future<Image?> getUserIcon(String id) {}

  // /// Update a users icon. as users do not have an icon,
  // /// this is not yet implemented
  // Future<bool?> updateUserIcon() {}

  /// return list of citizens from database based on guardian id
  Future<List<DisplayNameModel>?> getCitizens(String id) async {}

  /// Get all guardians for a citizen with id [id]
  Future<List<DisplayNameModel>?> getGuardians(String id) async {}

  /// Add a [guardianId] to a [citizenId]
  Future<bool?> addCitizenToGuardian(
      String guardianId, String citizenId) async {}

  // Week API functions

  /// Get all weeks from a user with the Id [id]
  Future<List<WeekNameModel>?> getWeekNames(String id) async {}

  /// Get a week base on
  /// [id] (User id)
  /// [year]
  /// [weekNumber]
  Future<WeekModel> getWeek(String id, int year, int weekNumber) async {}

  /// Update a week with all the fields in the given [week]
  /// With the userid [id]
  /// Year [year]
  /// And Weeknumber [weekNumber]
  Future<WeekModel> updateWeek(
      String id, int year, int weekNumber, WeekModel week) async {}

  /// Delete a Week With the userid [id]
  /// Year [year]
  /// And Weeknumber [weekNumber]
  Future<bool?> deleteWeek(String id, int year, int weekNumber) async {}

  // Week Template API functions

  /// Get all weekTemplateNameModels
  Future<List<WeekTemplateNameModel>?> getTemplateNames() async {}

  /// Create a week template in the database from [template]
  Future<WeekTemplateModel?> createTemplate(WeekTemplateModel template) async {}

  /// get a template by its [id]
  Future<WeekTemplateModel?> getTemplate(int id) async {}

  /// Update a template with all the values from [template]
  Future<WeekTemplateModel?> updateTemplate(WeekTemplateModel template) async {}

  /// Delete a template with the id [id]
  Future<bool?> deleteTemplate(int id) async {}

  /// Gets the version of the currently running db
  Future<int?> getCurrentDBVersion() async {}

  /// Force close the db
  Future<void> closeDb() async {}
}
