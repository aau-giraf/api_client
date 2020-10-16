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
  GirafUserModel registerAccount(Map<String, dynamic> body) {
    /*Map<String, dynamic> insertQuery = <String, dynamic>{
      ''
    }
    _database.insert('Users', body);
     _database.rawQuery('SELECT * FROM `Users` WHERE username')*/
  }

  bool deleteAccount(String id) {}

  // Activity API functions
  /// Add and activity to DB
  ActivityModel addActivity(ActivityModel activity, String userId,
      String weekplanName, int weekYear, int weekNumber, Weekday weekDay) {}

  ActivityModel updateActivity(ActivityModel activity, String userId) {}

  bool deleteActivity(int activityId, String userId) {}

  // Pictogram API functions
  List<PictogramModel> getAllPictograms(
      {String query, @required int page, @required int pageSize}) {}

  PictogramModel getPictogramID(int id) {}

  PictogramModel createPictogram(PictogramModel pictogram) {}

  PictogramModel updatePictogram(PictogramModel pictogram) {}

  bool deletePictogram(int id) {}

  PictogramModel updateImageInPictogram(int id, Uint8List image) {}

  Image getPictogramImage(int id) {}

  // User API functions
  GirafUserModel getMe() {
    return _me;
  }

  void setMe(GirafUserModel model) {
    _me = model;
  }

  GirafUserModel getUser(String id) {}

  GirafUserModel updateUser(GirafUserModel user) {}

  SettingsModel getUserSettings(String id) {}

  SettingsModel updateUserSettings(String id, SettingsModel settings) {}

  bool deleteUserIcon(String id) {}

  Image getUserIcon(String id) {}

  bool updateUserIcon() {}

  List<DisplayNameModel> getCitizens(String id) {}

  List<DisplayNameModel> getGuardians(String id) {}

  bool addCitizenToGuardian(String guardianId, String citizenId) {}

  // Week API functions

  List<WeekNameModel> getWeekNames(String id) {}

  WeekModel getWeek(String id, int year, int weekNumber) {}

  WeekModel updateWeek(String id, int year, int weekNumber, WeekModel week) {}

  bool deleteWeek(String id, int year, int weekNumber) {}

  // Week Template API functions

  List<WeekTemplateNameModel> getTemplateNames() {}

  WeekTemplateModel createTemplate(WeekTemplateModel template) {}

  WeekTemplateModel getTemplate(int id) {}

  WeekTemplateModel updateTemplate(WeekTemplateModel template) {}

  bool deleteTemplate(int id) {}

  /// Gets the version of the currently running db
  Future<int> getCurrentDBVersion() {
    return _database.getVersion();
  }

  /// Force close the db
  Future<void> closeDb() {
    _database.close();
  }
}
