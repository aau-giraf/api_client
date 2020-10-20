import 'dart:async';
import 'dart:typed_data';
import 'package:api_client/models/activity_model.dart';
import 'package:api_client/models/displayname_model.dart';
import 'package:api_client/models/enums/weekday_enum.dart';
import 'package:api_client/models/giraf_user_model.dart';
import 'package:api_client/models/pictogram_model.dart';
import 'package:api_client/models/settings_model.dart';
import 'package:api_client/models/timer_model.dart';
import 'package:api_client/models/week_model.dart';
import 'package:api_client/models/week_name_model.dart';
import 'package:api_client/models/week_template_model.dart';
import 'package:api_client/models/week_template_name_model.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

/// OfflineDbHandler is used for communication with the offline database
class OfflineDbHandler {
  ///Constructor for the dbhandler
  OfflineDbHandler(Database db) {
    _database = db;
    createTables();
  }
  Database _database;
  GirafUserModel _me;

  /// Initiate the database

  ///Creates all of the tables in the DB
  Future<void> createTables() async {
    await _database.transaction((Transaction txn) async {
      await txn.execute('CREATE TABLE IF NOT EXISTS `Users` ('
          '`OfflineId` varchar( 255 ) NOT NULL PRIMARY KEY AUTOINCREMENT, '
          '`Role` varchar ( 255 ) NOT NULL, '
          '`RoleName` varchar ( 256 ) DEFAULT NULL, '
          '`Username` varchar ( 256 ) DEFAULT NULL, '
          '`DisplayName` longtext NOT NULL, '
          '`Department` integer DEFAULT NULL, '
          '`Id` integer'
          'UNIQUE(`UserName`, `Id`));');
      await txn.execute('CREATE TABLE IF NOT EXISTS `GuardianRelations` ('
          '`OfflineId`	integer NOT NULL PRIMARY KEY AUTOINCREMENT, '
          '`CitizenId`	varchar ( 255 ) NOT NULL, '
          '`GuardianId`	varchar ( 255 ) NOT NULL, '
          'CONSTRAINT `FK_GuardianRelations_Users_CitizenId` '
          'FOREIGN KEY(`CitizenId`) '
          'REFERENCES `Users`(`OfflineId`) ON DELETE CASCADE, '
          'CONSTRAINT `FK_GuardianRelations_Users_GuardianId` '
          'FOREIGN KEY(`GuardianId`) '
          'REFERENCES `Users`(`OfflineId`) ON DELETE CASCADE);');
      await txn.execute('CREATE TABLE IF NOT EXISTS `WeekTemplates` ('
          '`id`	integer NOT NULL PRIMARY KEY AUTOINCREMENT, '
          '`Name`	longtext COLLATE BINARY, '
          '`ThumbnailKey`	integer NOT NULL, '
          'CONSTRAINT `FK_WeekTemplates_Pictograms_ThumbnailKey` '
          'FOREIGN KEY(`ThumbnailKey`) '
          'REFERENCES `Pictograms`(`id`) ON DELETE CASCADE);');
      await txn.execute('CREATE TABLE IF NOT EXISTS `Weeks` ('
          '`id`	integer NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, '
          '`GirafUserId`	varchar ( 255 ) NOT NULL, '
          '`Name`	longtext COLLATE BINARY, '
          '`ThumbnailKey`	integer NOT NULL, '
          '`WeekNumber`	integer NOT NULL, '
          '`WeekYear`	integer NOT NULL,'
          'CONSTRAINT `FK_Weeks_AspNetUsers_GirafUserId` '
          'FOREIGN KEY(`GirafUserId`) '
          'REFERENCES `Users`(`OfflineId`) ON DELETE CASCADE,'
          'CONSTRAINT `FK_Weeks_Pictograms_ThumbnailKey` '
          'FOREIGN KEY(`ThumbnailKey`) '
          'REFERENCES `Pictograms`(`id`) ON DELETE CASCADE);');
      await txn.execute('CREATE TABLE IF NOT EXISTS `Weekdays` ('
          '`id`	integer NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, '
          '`Day`	integer NOT NULL, '
          '`WeekId`	integer DEFAULT NULL, '
          '`WeekTemplateId`	integer DEFAULT NULL,'
          'CONSTRAINT `FK_Weekdays_WeekTemplates_WeekTemplateId` '
          'FOREIGN KEY(`WeekTemplateId`) '
          'REFERENCES `WeekTemplates`(`id`) ON DELETE CASCADE,'
          'CONSTRAINT `FK_Weekdays_Weeks_WeekId` '
          'FOREIGN KEY(`WeekId`) '
          'REFERENCES `Weeks`(`id`) ON DELETE CASCADE);');
      await txn.execute('CREATE TABLE IF NOT EXISTS `Pictograms` ('
          '`id`	integer NOT NULL PRIMARY KEY AUTOINCREMENT, '
          '`AccessLevel`	integer NOT NULL, '
          '`LastEdit`	datetime ( 6 ) NOT NULL, '
          '`Sound`	longblob, '
          '`Title`	varchar ( 255 ) NOT NULL, '
          '`ImageHash`	longtext COLLATE BINARY,'
          'UNIQUE(`id`,`Title`));');
      await txn.execute('CREATE TABLE IF NOT EXISTS `Activities` ('
          '`Key`	integer NOT NULL PRIMARY KEY AUTOINCREMENT, '
          '`Order`	integer NOT NULL, '
          '`OtherKey`	integer NOT NULL, '
          '`State`	integer NOT NULL, '
          '`TimerKey`	integer DEFAULT NULL, '
          '`IsChoiceBoard`	integer NOT NULL DEFAULT \'0\', '
          'CONSTRAINT `FK_Activities_Timers_TimerKey` '
          'FOREIGN KEY(`TimerKey`) '
          'REFERENCES `Timers`(`Key`) ON DELETE SET NULL,'
          'CONSTRAINT `FK_Activities_Weekdays_OtherKey` '
          'FOREIGN KEY(`OtherKey`) '
          'REFERENCES `Weekdays`(`id`) ON DELETE CASCADE);');
      await txn.execute('CREATE TABLE IF NOT EXISTS `PictogramRelations` ('
          '`ActivityId`	integer NOT NULL, '
          '`PictogramId`	integer NOT NULL, '
          'PRIMARY KEY(`ActivityId`,`PictogramId`), '
          'CONSTRAINT `FK_PictogramRelations_Activities_ActivityId` '
          'FOREIGN KEY(`ActivityId`) '
          'REFERENCES `Activities`(`Key`) ON DELETE CASCADE, '
          'CONSTRAINT `FK_PictogramRelations_Pictograms_PictogramId` '
          'FOREIGN KEY(`PictogramId`) '
          'REFERENCES `Pictograms`(`id`) ON DELETE CASCADE);');
      await txn.execute('CREATE TABLE IF NOT EXISTS `Timers` ('
          '`Key`	integer NOT NULL PRIMARY KEY AUTOINCREMENT, '
          '`StartTime`	integer NOT NULL, '
          '`Progress`	integer NOT NULL, '
          '`FullLength`	integer NOT NULL, '
          '`Paused`	integer NOT NULL);');
    });
  }

  // Account API functions
  /// register an account for a user
  Future<GirafUserModel> registerAccount(Map<String, dynamic> body) async {
    int roleID;
    switch (body['role']) {
      case 'Citizen':
        roleID = 0;
        break;
      case 'Department':
        roleID = 1;
        break;
      case 'Guardian':
        roleID = 2;
        break;
      case 'SuperUser':
        roleID = 3;
        break;
      default:
        roleID = 0;
    }
    final Map<String, dynamic> insertQuery = <String, dynamic>{
      'Role': roleID,
      'RoleName': body['role'],
      'UserName': body['username'],
      'DisplayName': body['displayname'],
      'Department': body['departmentId'],
    };
    _database.insert('Users', insertQuery);
    final List<Map<String, dynamic>> res = await _database.rawQuery(
        'SELECT * FROM `Users` WHERE `UserName` == ${body['username']}');
    return GirafUserModel.fromJson(res[0]);
  }

  /// Delete a user from the offline database
  Future<bool> deleteAccount(String id) async {
    final int res =
        await _database.rawDelete('DELETE * FROM `Users` WHERE `id` == $id');
    return res == 1;
  }

  // Activity API functions
  /// Add an activity to DB
  Future<ActivityModel> addActivity(
      ActivityModel activity,
      String userId,
      String weekplanName,
      int weekYear,
      int weekNumber,
      Weekday weekDay) async {
    final Map<String, dynamic> insertActivityQuery = <String, dynamic>{
      'Key': activity.id,
      'Order': activity.order,
      'OtherKey': weekNumber,
      'State': activity.state,
      'TimerKey': activity.timer.key,
      'IsChoiceBoard': activity.isChoiceBoard,
    };
    final Map<String, dynamic> insertTimerQuery = <String, dynamic>{
      'Key': activity.timer.key,
      'StartTime': activity.timer.startTime,
      'Progress': activity.timer.progress,
      'FullLength': activity.timer.fullLength,
      'Paused': activity.timer.paused,
    };
    _database.transaction((Transaction txn) async {
      for (PictogramModel pictogram in activity.pictograms) {
        await txn.insert('PictogramRelations', <String, dynamic>{
          'ActivityId': activity.id,
          'PictogramId': pictogram.id
        });
      }
    });
    await _database.insert('Activities', insertActivityQuery);
    await _database.insert('Timers', insertTimerQuery);
    return _getActivity(activity.id);
  }

  Future<ActivityModel> _getActivity(int key) async {
    final List<Map<String, dynamic>> listResult = await _database
        .rawQuery('SELECT * FROM `Activities` WHERE `Key` == $key');
    final Map<String, dynamic> result = listResult[0];
    final TimerModel timerModel = await _getTimer(result['TimerKey']);
    final List<PictogramModel> pictoList = await _getActivityPictograms(key);
    return ActivityModel.fromDatabase(result, timerModel, pictoList);
  }

  Future<List<PictogramModel>> _getActivityPictograms(int pictogramKey) async {
    final List<Map<String, dynamic>> res =
        await _database.rawQuery('SELECT * FROM `Pictogram` '
            'WHERE `Key` == (SELECT `PictogramId` FROM `PictogramRelations` '
            'WHERE `ActivityId` == $pictogramKey)');
    List<PictogramModel> result;
    for (Map<String, dynamic> pictogram in res) {
      result.add(PictogramModel.fromDatabase(pictogram));
    }
    return result;
  }

  Future<TimerModel> _getTimer(int key) async {
    final List<Map<String, dynamic>> res =
        await _database.rawQuery('SELECT * FROM `Timers` WHERE `Key` == $key');
    return TimerModel.fromDatabase(res[0]);
  }

  ///Update an [activity] from its id
  Future<ActivityModel> updateActivity(
      ActivityModel activity, String userId) async {
    await _database.rawUpdate('UPDATE `Activities` SET '
        'Order = ${activity.order}, '
        'State = ${activity.state}, '
        'TimerKey = ${activity.timer.key}, '
        'IsChoiceBoard = ${activity.isChoiceBoard} '
        'WHERE `Key` == $activity');
    await _database.rawUpdate('UPDATE `Timers` SET '
        'StartTime = ${activity.timer.startTime}, '
        'Progress = ${activity.timer.progress}, '
        'FullLength = ${activity.timer.fullLength}, '
        'Paused = ${activity.timer.paused} '
        'WHERE Key == ${activity.timer.key}');
    _database.transaction((Transaction txn) async {
      await txn.rawDelete('DELETE FROM `PictogramRelations` '
          'WHERE ActivityId = ${activity.id}');
      for (PictogramModel pictogram in activity.pictograms) {
        await txn.insert('PictogramRelations', <String, dynamic>{
          'ActivityId': activity.id,
          'PictogramId': pictogram.id
        });
      }
    });
    return _getActivity(activity.id);
  }

  ///Delete an activity with the id [activityId]
  Future<bool> deleteActivity(int activityId, String userId) async {
    final List<Map<String, dynamic>> res = await _database
        .rawQuery('SELECT TimerKey FROM `Activities` WHERE Key == $activityId');
    final int timerKey = res[0]['TimerKey'];
    final int activityChanged = await _database
        .rawDelete('DELETE FROM `Activities` WHERE Key == $activityId');
    final int timersChanged = await _database
        .rawDelete('DELETE FROM `Timers` WHERE Key == $timerKey');
    final int relationsChanged = await _database.rawDelete(
        'DELETE FROM `PictogramRelations` WHERE ActivityId == $activityId');
    return activityChanged == 1 && timersChanged == 1 && relationsChanged >= 1;
  }

  // Pictogram API functions
  ///Get [pageSize] pictograms by adding all pictograms to a list
  ///and split them into lists with size [pageSize] and then choose
  ///list number [page]
  Future<List<PictogramModel>> getAllPictograms(
      {String query, @required int page, @required int pageSize}) async {
    final List<Map<String, dynamic>> res =
        await _database.rawQuery('SELECT * FROM `Pictograms` '
            'WHERE Title LIKE %$query%');
    List<PictogramModel> allPictograms;
    for (Map<String, dynamic> pictogram in res) {
      allPictograms.add(PictogramModel.fromDatabase(pictogram));
    }
    List<List<PictogramModel>> possibleResults;
    for (int i = 0; i < allPictograms.length; i += pageSize) {
      possibleResults.add(allPictograms.sublist(
          i,
          i + pageSize > allPictograms.length
              ? allPictograms.length
              : i + pageSize));
    }
    return possibleResults[page];
  }

  ///Get the pictogram with the id [id]
  Future<PictogramModel> getPictogramID(int id) async {
    final List<Map<String, dynamic>> res =
        await _database.rawQuery('SELECT * FROM `Pictograms` WHERE id == $id');
    return PictogramModel.fromDatabase(res[0]);
  }

  ///Add a pictogram to the offline database
  Future<PictogramModel> createPictogram(PictogramModel pictogram) {
    final Map<String, dynamic> insertQuery = <String, dynamic>{
      'id': pictogram.id,
      'AccessLevel': pictogram.accessLevel,
      'LastEdit': pictogram.lastEdit,
      'Title': pictogram.title,
      'Imagehash': pictogram.imageHash,
    };
    _database.insert('Pictograms', insertQuery);
    return getPictogramID(pictogram.id);
  }

  ///Update a given pictogram
  Future<PictogramModel> updatePictogram(PictogramModel pictogram) async {
    await _database.rawUpdate('UPDATE `Pictograms` SET '
        'AccessLevel = ${pictogram.accessLevel}, '
        'LastEdit = ${pictogram.lastEdit}, '
        'Title = ${pictogram.title}, '
        'ImageHash = ${pictogram.imageHash} '
        'WHERE id == ${pictogram.id}');
    return getPictogramID(pictogram.id);
  }

  Future<bool> deletePictogram(int id) async {
    final int pictogramsDeleted =
        await _database.rawDelete('DELETE FROM `Pictograms` WHERE id == $id');
    return pictogramsDeleted == 1;
  }

  Future<PictogramModel> updateImageInPictogram(int id, Uint8List image) {}

  Future<Image> getPictogramImage(int id) {}

  // User API functions
  GirafUserModel getMe() {
    return _me;
  }

  void setMe(GirafUserModel model) {
    _me = model;
  }

  Future<GirafUserModel> getUser(String id) {}

  Future<GirafUserModel> updateUser(GirafUserModel user) {}

  Future<SettingsModel> getUserSettings(String id) {}

  Future<SettingsModel> updateUserSettings(String id, SettingsModel settings) {}

  Future<bool> deleteUserIcon(String id) {}

  Future<Image> getUserIcon(String id) {}

  Future<bool> updateUserIcon() {}

  Future<List<DisplayNameModel>> getCitizens(String id) {}

  Future<List<DisplayNameModel>> getGuardians(String id) {}

  Future<bool> addCitizenToGuardian(String guardianId, String citizenId) {}

  // Week API functions

  Future<List<WeekNameModel>> getWeekNames(String id) {}

  Future<WeekModel> getWeek(String id, int year, int weekNumber) {}

  Future<WeekModel> updateWeek(
      String id, int year, int weekNumber, WeekModel week) {}

  Future<bool> deleteWeek(String id, int year, int weekNumber) {}

  // Week Template API functions

  Future<List<WeekTemplateNameModel>> getTemplateNames() {}

  Future<WeekTemplateModel> createTemplate(WeekTemplateModel template) {}

  Future<WeekTemplateModel> getTemplate(int id) {}

  Future<WeekTemplateModel> updateTemplate(WeekTemplateModel template) {}

  Future<bool> deleteTemplate(int id) {}

  /// Gets the version of the currently running db
  Future<int> getCurrentDBVersion() {
    return _database.getVersion();
  }

  /// Force close the db
  Future<void> closeDb() async {
    await _database.close();
  }
}
