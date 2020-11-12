import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:api_client/api_client.dart';
import 'package:api_client/http/http.dart';
import 'package:api_client/models/activity_model.dart';
import 'package:api_client/models/displayname_model.dart';
import 'package:api_client/models/enums/cancel_mark_enum.dart';
import 'package:api_client/models/enums/complete_mark_enum.dart';
import 'package:api_client/models/enums/default_timer_enum.dart';
import 'package:api_client/models/enums/giraf_theme_enum.dart';
import 'package:api_client/models/enums/weekday_enum.dart';
import 'package:api_client/models/giraf_user_model.dart';
import 'package:api_client/models/pictogram_model.dart';
import 'package:api_client/models/settings_model.dart';
import 'package:api_client/models/timer_model.dart';
import 'package:api_client/models/week_model.dart';
import 'package:api_client/models/week_name_model.dart';
import 'package:api_client/models/week_template_model.dart';
import 'package:api_client/models/week_template_name_model.dart';
import 'package:api_client/models/weekday_color_model.dart';
import 'package:api_client/persistence/persistence_client.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

/// OfflineDbHandler is used for communication with the offline database
class OfflineDbHandler {
  ///Constructor for the dbhandler
  @visibleForTesting
  OfflineDbHandler();

  /// The current running instance of the database
  static final OfflineDbHandler instance = OfflineDbHandler();
  static Database _database;

  GirafUserModel _me;

  /// Get the database, if it doesnt exist create it
  Future<Database> get database async {
    if (_database == null) {
      return initializeDatabase();
    }
    return _database;
  }

  /// Return the directory where pictograms are saved
  Future<String> get getPictogramDirectory async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final Directory imageDirectory =
        Directory(join(directory.path, 'pictograms'));
    imageDirectory.createSync();
    return imageDirectory.path;
  }

  /// Initiate the database
  Future<Database> initializeDatabase() async {
    return openDatabase(join(await getDatabasesPath(), 'offlineGiraf'),
        version: 1, onCreate: (Database db, int version) async {
      createTables(db);
    });
  }

  ///Creates all of the tables in the DB
  Future<void> createTables(Database db) async {
    await db.transaction((Transaction txn) async {
      await txn.execute('CREATE TABLE IF NOT EXISTS `Users` ('
          '`OfflineId` integer NOT NULL PRIMARY KEY AUTOINCREMENT, '
          '`Role` integer NOT NULL, '
          '`RoleName` varchar ( 255 ) DEFAULT NULL, '
          '`Username` varchar ( 255 ) DEFAULT NULL UNIQUE, '
          '`DisplayName` longtext NOT NULL, '
          '`Department` integer DEFAULT NULL, '
          '`Password` char(128) NOT NULL, '
          '`SettingsKey` integer DEFAULT NULL, '
          '`Id` integer, '
          'UNIQUE(`UserName`, `Id`)'
          'CONSTRAINT `FK_AspNetUsers_Setting_SettingsKey` '
          'FOREIGN KEY(`SettingsKey`) '
          'REFERENCES `Setting`(`Key`) ON DELETE RESTRICT);');
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
          '`OnlineId` integer NOT NULL, '
          '`Department` integer, '
          'CONSTRAINT `FK_WeekTemplates_Pictograms_ThumbnailKey` '
          'FOREIGN KEY(`ThumbnailKey`) '
          'REFERENCES `Pictograms`(`OnlineId`) ON DELETE CASCADE);');
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
          'REFERENCES `Pictograms`(`OnlineId`) ON DELETE CASCADE);');
      await txn.execute('CREATE TABLE IF NOT EXISTS `Weekdays` ('
          '`id`	integer NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, '
          '`Day`	integer NOT NULL, '
          '`WeekId`	integer DEFAULT NULL, '
          '`WeekTemplateId`	integer DEFAULT NULL,'
          'CONSTRAINT `FK_Weekdays_WeekTemplates_WeekTemplateId` '
          'FOREIGN KEY(`WeekTemplateId`) '
          'REFERENCES `WeekTemplates`(`OnlineId`) ON DELETE CASCADE,'
          'CONSTRAINT `FK_Weekdays_Weeks_WeekId` '
          'FOREIGN KEY(`WeekId`) '
          'REFERENCES `Weeks`(`id`) ON DELETE CASCADE);');
      await txn.execute('CREATE TABLE IF NOT EXISTS `Pictograms` ('
          '`id`	integer NOT NULL PRIMARY KEY AUTOINCREMENT, '
          '`AccessLevel`	integer NOT NULL, '
          '`LastEdit`	datetime ( 6 ) NOT NULL, '
          '`Sound`	longblob, '
          '`Title`	varchar ( 255 ) NOT NULL, '
          '`ImageHash`	longtext COLLATE BINARY, '
          '`OnlineId` integer NOT NULL UNIQUE, '
          'UNIQUE(`id`,`Title`));');
      await txn.execute('CREATE TABLE IF NOT EXISTS `Activities` ('
          '`Key` integer NOT NULL PRIMARY KEY AUTOINCREMENT, '
          '`Order` integer NOT NULL, '
          '`OtherKey`	integer NOT NULL, '
          '`State` integer NOT NULL, '
          '`TimerKey`	integer DEFAULT NULL, '
          '`IsChoiceBoard` integer NOT NULL DEFAULT \'0\', '
          'CONSTRAINT `FK_Activities_Timers_TimerKey` '
          'FOREIGN KEY(`TimerKey`) '
          'REFERENCES `Timers`(`Key`) ON DELETE SET NULL,'
          'CONSTRAINT `FK_Activities_Weekdays_OtherKey` '
          'FOREIGN KEY(`OtherKey`) '
          'REFERENCES `Weekdays`(`id`) ON DELETE CASCADE);');
      await txn.execute('CREATE TABLE IF NOT EXISTS `PictogramRelations` ('
          '`ActivityId`	integer NOT NULL, '
          '`PictogramId` integer NOT NULL, '
          'PRIMARY KEY(`ActivityId`,`PictogramId`), '
          'CONSTRAINT `FK_PictogramRelations_Activities_ActivityId` '
          'FOREIGN KEY(`ActivityId`) '
          'REFERENCES `Activities`(`Key`) ON DELETE CASCADE, '
          'CONSTRAINT `FK_PictogramRelations_Pictograms_PictogramId` '
          'FOREIGN KEY(`PictogramId`) '
          'REFERENCES `Pictograms`(`OnlineId`) ON DELETE CASCADE);');
      await txn.execute('CREATE TABLE IF NOT EXISTS `Timers` ('
          '`Key` integer NOT NULL PRIMARY KEY AUTOINCREMENT, '
          '`StartTime`	integer NOT NULL, '
          '`Progress`	integer NOT NULL, '
          '`FullLength`	integer NOT NULL, '
          '`Paused`	integer NOT NULL);');
      await txn
          .execute('CREATE TABLE IF NOT EXISTS `FailedOnlineTransactions` ('
              '`Type` varchar (7) NOT NULL, '
              '`Url` varchar (255) NOT NULL, '
              '`Body` varchar (255), '
              // TableAffected is used to know where to change an id if needed
              '`TableAffected` varchar (255), '
              '`TempId` varchar(255));');
      await txn.execute('CREATE TABLE IF NOT EXISTS `WeekDayColors` ('
          '`Id`	integer NOT NULL PRIMARY KEY AUTOINCREMENT,'
          '`Day` integer NOT NULL,'
          '`HexColor`	longtext COLLATE BINARY,'
          '`SettingId` integer NOT NULL,'
          '	CONSTRAINT `FK_WeekDayColors_Setting_SettingId` '
          'FOREIGN KEY(`SettingId`) '
          'REFERENCES `Setting`(`Key`) ON DELETE CASCADE'
          ');');
      await txn.execute('CREATE TABLE IF NOT EXISTS `Setting` ('
          '`Key` integer NOT NULL PRIMARY KEY AUTOINCREMENT, '
          '`ActivitiesCount` integer DEFAULT NULL,'
          '`CancelMark`	integer NOT NULL,'
          '`CompleteMark`	integer NOT NULL,'
          '`DefaultTimer`	integer NOT NULL,'
          '`GreyScale` integer NOT NULL,'
          '`NrOfDaysToDisplay` integer DEFAULT NULL,'
          '`Orientation` integer NOT NULL,'
          '`Theme` integer NOT NULL,'
          '`TimerSeconds`	integer DEFAULT NULL,'
          "`LockTimerControl`	integer NOT NULL DEFAULT '0',"
          "`PictogramText` integer NOT NULL DEFAULT '0'"
          ');');
    });
  }

  // offline to online functions
  /// Save failed online transactions
  /// [type] transaction type
  /// [baseUrl] baseUrl from the http
  /// [url] Url to send the transaction to
  /// [body] the json to send to the online database
  /// [tableAffected] NEEDS to be set when we try to create objects with public
  /// id's we need to have syncronized between the offline and online database
  Future<void> saveFailedTransactions(String type, String baseUrl, String url,
      {Map<String, dynamic> body, String tableAffected, String tempId}) async {
    final Database db = await database;
    final Map<String, dynamic> insertQuery = <String, dynamic>{
      'Type': type,
      'Url': baseUrl + url,
      'Body': body.toString(),
      'TableAffected': tableAffected,
      'TempId': tempId
    };
    db.insert('`FailedOnlineTransactions`', insertQuery);
  }

  /// Retry sending the failed changes to the online database
  Future<void> retryFailedTransactions() async {
    final Database db = await database;

    final List<Map<String, dynamic>> dbRes =
        await db.rawQuery('SELECT * FROM `FailedOnlineTransactions`');
    if (dbRes.isNotEmpty) {
      final Http _http = HttpClient(baseUrl: '', persist: PersistenceClient());
      for (Map<String, dynamic> transaction in dbRes) {
        switch (transaction['Type']) {
          case 'DELETE':
            _http.delete(transaction['Url']).listen((Response res) {
              if (res.success()) {
                removeFailedTransaction(transaction);
              }
            });
            break;
          case 'POST':
            _http
                .post(transaction['Url'], transaction['Body'])
                .listen((Response res) {
              if (res.success()) {
                removeFailedTransaction(transaction);
                updateIdInOfflineDb(res.json, transaction['TableAffected'],
                    transaction['TempId']);
              }
            });
            break;
          case 'PATCH':
            _http
                .patch(transaction['Url'], transaction['Body'])
                .listen((Response res) {
              if (res.success()) {
                removeFailedTransaction(transaction);
              }
            });
            break;
          case 'PUT':
            _http
                .put(transaction['Url'], transaction['Body'])
                .listen((Response res) {
              if (res.success()) {
                removeFailedTransaction(transaction);
              }
            });
            break;
          default:
            throw const HttpException('invalid request type');
        }
      }
    }
  }

  /// Update the an Id in the database with a new one from the online database,
  /// once the online is done creating them. The [json] contains the key
  /// [table] is the table to be changed
  /// [tempId] is the id assigned when the object was created offline
  Future<void> updateIdInOfflineDb(
      Map<String, dynamic> json, String table, String tempId) async {
    switch (table) {
      case 'Users':
        replaceTempIdUsers(tempId, json['id']);
        break;
      case 'Pictograms':
        replaceTempIdPictogram(tempId, json['id']);
        break;
      case 'WeekTemplates':
        replaceTempIdWeekTemplate(tempId, json['id']);
        break;
      default:
        break;
    }
  }

  /// Replace the id of a User
  /// Should be called to replace the id given by this class with the one in the
  /// online database, such that they are synchonized
  Future<void> replaceTempIdUsers(String oldId, String newId) async {
    final Database db = await database;
    db.rawUpdate("UPDATE `Users` SET Id = '$newId' "
        "WHERE Id == '$oldId'");
    db.rawUpdate("UPDATE `GuardianRelations` SET CitizenId = '$newId' "
        "WHERE CitizenId == '$oldId'");
    db.rawUpdate("UPDATE `GuardianRelations` SET GuardianId = '$newId' "
        "WHERE GuardianId == '$oldId'");
    db.rawUpdate("UPDATE `Weeks` SET GirafUserId = '$newId' "
        "WHERE GirafUserId == '$oldId'");
  }

  /// Replace the id of a Pictogram
  /// Should be called to replace the id given by this class with the one in the
  /// online database, such that they are synchonized
  Future<void> replaceTempIdPictogram(String oldId, String newId) async {
    final Database db = await database;
    db.rawUpdate("UPDATE `Pictogram` SET Id = '$newId' "
        "WHERE Id == '$oldId'");
    db.rawUpdate("UPDATE `WeekTemplates` SET ThumbnailKey = '$newId'"
        " WHERE ThumbnailKey == '$oldId'");
    db.rawUpdate("UPDATE `Weeks` SET ThumbnailKey = '$newId'"
        " WHERE ThumbnailKey == '$oldId'");
    db.rawUpdate("UPDATE `PictogramRelations` SET PictogramId = '$newId'"
        " WHERE PictogramId == '$oldId'");
  }

  /// Replace the id of a Pictogram
  /// Should be called to replace the id given by this class with the one in the
  /// online database, such that they are synchonized
  Future<void> replaceTempIdWeekTemplate(String oldId, String newId) async {
    final Database db = await database;
    db.rawUpdate("UPDATE `WeekTemplates` SET OnlineId = '$newId' "
        "Where OnlineId == '$oldId'");
    db.rawUpdate("UPDATE `Weekdays` SET WeekTemplateId = '$newId' "
        "Where WeekTemplateId == '$oldId'");
  }

  /// Remove a previously failed transaction from the
  /// offline database when it succeeds
  Future<void> removeFailedTransaction(Map<String, dynamic> transaction) async {
    final Database db = await database;
    db.rawDelete('DELETE * FROM `FailedOnlineTransactions` WHERE '
        "Type == '${transaction['Type']}' AND "
        "Url == '${transaction['Url']}' AND "
        "Body == '${transaction['Body']}' AND "
        "TableAffected == '${transaction['TableAffected']}' AND "
        "TempId == '${transaction['TempId']}'");
  }

  // Account API functions
  /// Returns [true] if [password] matches the password saved for [username]
  Future<bool> login(String username, String password) async {
    final Database db = await database;
    final List<Map<String, dynamic>> res = await db
        .rawQuery("SELECT Password FROM `Users` WHERE Username == '$username'");
    return sha512.convert(utf8.encode(password)).toString() ==
        res[0]['Password'];
  }

  /// register an account for a user
  Future<GirafUserModel> registerAccount(Map<String, dynamic> body) async {
    final Database db = await database;
    final List<Map<String, dynamic>> count = await db.rawQuery(
        "SELECT * FROM `Users` WHERE Username == '${body['username']}'");
    if (count.isNotEmpty) {
      // TODO(Tilasair): better exceptions
      throw Exception('Username already exists');
    }
    final Map<String, dynamic> settings = <String, dynamic>{
      'ActivitiesCount': 0,
      'CancelMark': CancelMark.Cross.index,
      'CompleteMark': CompleteMark.Checkmark.index,
      'DefaultTimer': DefaultTimer.PieChart.index,
      'GreyScale': 0, //false
      'NrOfDaysToDisplay': 7,
      'Orientation': Orientation.portrait.index,
      'Theme': GirafTheme.GirafYellow.index,
      'TimerSeconds': 900,
      'LockTimerControl': 0, //false
      'PictogramText': 0 //false
    };
    await db.insert('Setting', settings);
    final List<Map<String, dynamic>> settingsIdRes =
        await db.rawQuery('SELECT `Key` FROM `Setting` WHERE `Key` NOT IN '
            '(SELECT `SettingsKey` FROM `Users`)');
    final int settingsId = settingsIdRes[0]['Key'];
    await db.insert('WeekDayColors', <String, dynamic>{
      'Day': Weekday.Monday.index,
      'HexColor': '#08a045',
      'SettingId': settingsId
    });
    await db.insert('WeekDayColors', <String, dynamic>{
      'Day': Weekday.Tuesday.index,
      'HexColor': '#540d6e',
      'SettingId': settingsId
    });
    await db.insert('WeekDayColors', <String, dynamic>{
      'Day': Weekday.Wednesday.index,
      'HexColor': '#f77f00',
      'SettingId': settingsId
    });
    await db.insert('WeekDayColors', <String, dynamic>{
      'Day': Weekday.Thursday.index,
      'HexColor': '#004777',
      'SettingId': settingsId
    });
    await db.insert('WeekDayColors', <String, dynamic>{
      'Day': Weekday.Friday.index,
      'HexColor': '#f9c80e',
      'SettingId': settingsId
    });
    await db.insert('WeekDayColors', <String, dynamic>{
      'Day': Weekday.Saturday.index,
      'HexColor': '#db2b39',
      'SettingId': settingsId
    });
    await db.insert('WeekDayColors', <String, dynamic>{
      'Day': Weekday.Sunday.index,
      'HexColor': '#ffffff',
      'SettingId': settingsId
    });
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
      'Username': body['username'],
      'DisplayName': body['displayName'],
      'Department': body['department'],
      'SettingsKey': settingsId,
      'password': sha512.convert(utf8.encode(body['password'])).toString(),
      'Id': Uuid().v1()
    };
    await db.insert('Users', insertQuery);
    final List<Map<String, dynamic>> res = await db.rawQuery(
        "SELECT * FROM `Users` WHERE `Username` == '${body['username']}'");
    return GirafUserModel.fromDatabase(res[0]);
  }

  /// Do not call this function without ensuring that the password is
  /// successfully changed online
  /// change a password
  Future<bool> changePassword(String id, String newPassword) async {
    final Database db = await database;
    final String encryptedPassword =
        sha512.convert(utf8.encode(newPassword)).toString();
    final int rowsChanged = await db.rawUpdate(
        "UPDATE `Users` SET Password = '$encryptedPassword' WHERE Id == '$id'");
    return rowsChanged == 1;
  }

  /// Delete a user from the offline database
  Future<bool> deleteAccount(String id) async {
    final Database db = await database;
    final int res =
        await db.rawDelete("DELETE * FROM `Users` WHERE `Id` == '$id'");
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
      'IsChoiceBoard': activity.isChoiceBoard,
    };
    Map<String, dynamic> insertTimerQuery;
    if (activity.timer != null) {
      insertActivityQuery['TimerKey'] = activity.timer.key;
      insertTimerQuery = <String, dynamic>{
        'Key': activity.timer.key,
        'StartTime': activity.timer.startTime,
        'Progress': activity.timer.progress,
        'FullLength': activity.timer.fullLength,
        'Paused': activity.timer.paused,
      };
    }

    final Database db = await database;
    db.transaction((Transaction txn) async {
      for (PictogramModel pictogram in activity.pictograms) {
        await txn.insert('PictogramRelations', <String, dynamic>{
          'ActivityId': activity.id,
          'PictogramId': pictogram.id
        });
      }
    });
    await db.insert('Activities', insertActivityQuery);
    if (insertTimerQuery != null) {
      await db.insert('Timers', insertTimerQuery);
    }
    return _getActivity(activity.id);
  }

  Future<ActivityModel> _getActivity(int key) async {
    final Database db = await database;
    final List<Map<String, dynamic>> listResult =
        await db.rawQuery("SELECT * FROM `Activities` WHERE `Key` == '$key'");
    final Map<String, dynamic> result = listResult[0];
    final TimerModel timerModel =
        result != null ? await _getTimer(result['TimerKey']) : null;
    final List<PictogramModel> pictoList = await _getActivityPictograms(key);
    return ActivityModel.fromDatabase(result, timerModel, pictoList);
  }

  Future<List<PictogramModel>> _getActivityPictograms(int activityKey) async {
    final Database db = await database;
    final List<Map<String, dynamic>> res = await db.rawQuery(
        'SELECT * FROM `Pictograms` '
        'WHERE `OnlineId` == (SELECT `PictogramId` FROM `PictogramRelations` '
        "'WHERE `ActivityId` == '$activityKey)'");
    List<PictogramModel> result;
    for (Map<String, dynamic> pictogram in res) {
      result.add(PictogramModel.fromDatabase(pictogram));
    }
    return result;
  }

  Future<TimerModel> _getTimer(int key) async {
    final Database db = await database;
    final List<Map<String, dynamic>> res =
        await db.rawQuery("SELECT * FROM `Timers` WHERE `Key` == '$key'");
    return TimerModel.fromDatabase(res[0]);
  }

  ///Update an [activity] from its id
  Future<ActivityModel> updateActivity(
      ActivityModel activity, String userId) async {
    final Database db = await database;
    await db.rawUpdate('UPDATE `Activities` SET '
        "Order = '${activity.order}', "
        "State = '${activity.state}', "
        "TimerKey = '${activity.timer.key}', "
        "IsChoiceBoard = '${activity.isChoiceBoard}' "
        "WHERE `Key` == '$activity'");
    await db.rawUpdate('UPDATE `Timers` SET '
        "StartTime = '${activity.timer.startTime}', "
        "Progress = '${activity.timer.progress}', "
        "FullLength = '${activity.timer.fullLength}', "
        "Paused = '${activity.timer.paused}' "
        "WHERE Key == '${activity.timer.key}'");
    db.transaction((Transaction txn) async {
      await txn.rawDelete('DELETE FROM `PictogramRelations` '
          "WHERE ActivityId = '${activity.id}'");
      for (PictogramModel pictogram in activity.pictograms) {
        await txn.insert('PictogramRelations', <String, dynamic>{
          'ActivityId': activity.id,
          'OnlineId': pictogram.id
        });
      }
    });
    return _getActivity(activity.id);
  }

  ///Delete an activity with the id [activityId]
  Future<bool> deleteActivity(int activityId, String userId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> res = await db.rawQuery(
        "SELECT TimerKey FROM `Activities` WHERE Key == '$activityId'");
    final int timerKey = res[0]['TimerKey'];
    final int activityChanged = await db
        .rawDelete("DELETE FROM `Activities` WHERE Key == '$activityId'");
    final int timersChanged =
        await db.rawDelete("DELETE FROM `Timers` WHERE Key == '$timerKey'");
    final int relationsChanged = await db.rawDelete(
        "DELETE FROM `PictogramRelations` WHERE ActivityId == '$activityId'");
    return activityChanged == 1 && timersChanged == 1 && relationsChanged >= 1;
  }

  // Pictogram API functions
  ///Get [pageSize] pictograms by adding all pictograms to a list
  ///and split them into lists with size [pageSize] and then choose
  ///list number [page]
  Future<List<PictogramModel>> getAllPictograms(
      {String query, @required int page, @required int pageSize}) async {
    final Database db = await database;
    final List<Map<String, dynamic>> res =
        await db.rawQuery('SELECT * FROM `Pictograms` '
            "WHERE Title LIKE '%$query%'");
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
    final Database db = await database;
    final List<Map<String, dynamic>> res =
        await db.rawQuery("SELECT * FROM `Pictograms` WHERE OnlineId == '$id'");
    return PictogramModel.fromDatabase(res[0]);
  }

  ///Add a pictogram to the offline database
  Future<PictogramModel> createPictogram(PictogramModel pictogram) async {
    final Database db = await database;
    final Map<String, dynamic> insertQuery = <String, dynamic>{
      'OnlineId': pictogram.id ?? Uuid().v1().hashCode,
      'AccessLevel': pictogram.accessLevel.index,
      'LastEdit': pictogram.lastEdit.toIso8601String(),
      'Title': pictogram.title,
      'ImageHash': pictogram.imageHash,
    };
    await db.insert('Pictograms', insertQuery);
    return getPictogramID(pictogram.id);
  }

  ///Update a given pictogram
  Future<PictogramModel> updatePictogram(PictogramModel pictogram) async {
    final Database db = await database;
    await db.rawUpdate('UPDATE `Pictograms` SET '
        "AccessLevel = '${pictogram.accessLevel.index}', "
        "LastEdit = '${pictogram.lastEdit}', "
        "Title = '${pictogram.title}', "
        "ImageHash = '${pictogram.imageHash}' "
        "WHERE OnlineId == '${pictogram.id}'");
    return getPictogramID(pictogram.id);
  }

  /// Delete a pictogram with the id [id]
  Future<bool> deletePictogram(int id) async {
    final Database db = await database;
    final int pictogramsDeleted =
        await db.rawDelete("DELETE FROM `Pictograms` WHERE OnlineId == '$id'");
    final String pictogramDirectoryPath = await getPictogramDirectory;
    try {
      await File(join(pictogramDirectoryPath, '$id.png')).delete();
    } on FileSystemException catch (_) {}
    return pictogramsDeleted == 1;
  }

  /// Update an image in the pictogram table
  Future<PictogramModel> updateImageInPictogram(int id, Uint8List image) async {
    final Database db = await database;
    final String pictogramDirectoryPath = await getPictogramDirectory;
    final File newImage = File(join(pictogramDirectoryPath, '$id.png'));
    newImage.writeAsBytes(image);
    final List<Map<String, dynamic>> res =
        await db.rawQuery("SELECT * FROM `Pictograms` WHERE OnlineId == '$id'");
    return PictogramModel.fromDatabase(res[0]);
  }

  /// Get an image from the local pictogram directory
  Future<Image> getPictogramImage(int id) async {
    final String pictogramDirectoryPath = await getPictogramDirectory;
    final File pictogramFile = File(join(pictogramDirectoryPath, '$id.png'));
    return Image.file(pictogramFile);
  }

  // User API functions
  /// Return the me value
  GirafUserModel getMe() {
    return _me;
  }

  /// Set the me value
  void setMe(GirafUserModel model) {
    _me = model;
  }

  /// Get a user
  Future<GirafUserModel> getUser(String id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> res =
        await db.rawQuery("SELECT * `Users` WHERE id == '$id'");
    return GirafUserModel.fromDatabase(res[0]);
  }

  //Get User Id
  // ignore: public_member_api_docs
  Future<String> getUserId(String userName) async {
    final Database db = await database;
    final List<Map<String, dynamic>> id = await db
        .rawQuery("SELECT * FROM `Users` WHERE username == '$userName'");
    return GirafUserModel.fromDatabase(id[0]).id;
  }

  /// Update a user based on [user.id] with the values from [user]
  Future<GirafUserModel> updateUser(GirafUserModel user) async {
    final Database db = await database;
    await db.rawUpdate('UPDATE `Users` SET '
        "Role = '${user.role}', "
        "RoleName = '${user.roleName}', "
        "Username = '${user.username}', "
        "DisplayName = '${user.displayName}', "
        "Department = '${user.department}' "
        "WHERE Id == '${user.id}'");
    return getUser(user.id);
  }

  /// Get a the relevant settings for a user with the id: [id]
  Future<SettingsModel> getUserSettings(String id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> resSettings =
        await db.rawQuery('SELECT * FROM `Setting` WHERE '
            "`Key` == (SELECT `SettingsKey` FROM `Users` WHERE `Id` == '$id')");
    final List<Map<String, dynamic>> resWeekdayColors =
        await db.rawQuery('SELECT * FROM `WeekDayColors` WHERE '
            "`Id` == '${resSettings[0]['Key']}'");
    return SettingsModel.fromDatabase(resSettings[0], resWeekdayColors);
  }

  /// Update the settings for a Girafuser with the id: [id]
  Future<SettingsModel> updateUserSettings(
      String id, SettingsModel settings) async {
    final Database db = await database;
    final List<Map<String, dynamic>> res =
        await db.rawQuery('SELECT `SettingsKey` FROM `Users` '
            'WHERE `Id` == $id');
    final String settingsKey = res[0]['SettingsKey'];
    db.rawUpdate('UPDATE `Setting` SET '
        "`ActivitiesCount` = '${settings.activitiesCount}', "
        "`CancelMark` = '${settings.cancelMark}', "
        "`CompleteMark` = '${settings.completeMark}', "
        "`DefaultTimer` = '${settings.defaultTimer}', "
        "`GreyScale` = '${settings.greyscale}', "
        "`NrOfDaysToDisplay` = '${settings.nrOfDaysToDisplay}', "
        "`Orientation` = '${settings.orientation}', "
        "`Theme` = '${settings.theme}', "
        "`TimerSeconds` = '${settings.timerSeconds}', "
        "`LockTimerControl` = '${settings.lockTimerControl}', "
        "`PictogramText` = '${settings.pictogramText}' WHERE "
        "`Key` = '$settingsKey'");
    for (WeekdayColorModel dayColor in settings.weekDayColors) {
      final int day = dayColor.day.index;
      db.rawUpdate('UPDATE `WeekDayColors` SET '
          "`HexColor` = '${dayColor.hexColor}' WHERE "
          "`SettingsId` == '$settingsKey' AND "
          "`Day` == '$day'");
    }
    return getUserSettings(id);
  }

  /// Delete a users icon. as users do not have an icon,
  /// this is not yet implementet
  Future<bool> deleteUserIcon(String id) {
    throw UnimplementedError();
  }

  /// Get a users icon. as users do not have an icon,
  /// this is not yet implementet
  Future<Image> getUserIcon(String id) {
    throw UnimplementedError();
  }

  /// Update a users icon. as users do not have an icon,
  /// this is not yet implementet
  Future<bool> updateUserIcon() {
    throw UnimplementedError();
  }

  /// return list of citizens from database based on guardian id
  Future<List<DisplayNameModel>> getCitizens(String id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> res =
        await db.rawQuery('SELECT * FROM `Users` AS `U` JOIN'
            ' `GuardianRelations` AS `GR` ON `U`.Id==`GR`.CitizenId '
            "WHERE `GR`.GuardianId =='$id'");
    return res
        .map<DisplayNameModel>((Map<String, dynamic> citizenJson) =>
            DisplayNameModel.fromDatabase(citizenJson))
        .toList();
  }

  ///
  Future<List<DisplayNameModel>> getGuardians(String id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> res =
        await db.rawQuery('SELECT * FROM `Users` AS `U` JOIN'
            ' `GuardianRelations` AS `GR` ON `U`.Id==`GR`.GuardianId '
            "WHERE `GR`.CitizenId =='$id'");
    return res
        .map<DisplayNameModel>((Map<String, dynamic> citizenJson) =>
            DisplayNameModel.fromDatabase(citizenJson))
        .toList();
  }

  /// Add a [guardianId] to a [citizenId]
  Future<bool> addCitizenToGuardian(String guardianId, String citizenId) async {
    final Database db = await database;
    final Map<String, dynamic> insertQuery = <String, dynamic>{
      'GuardianId': guardianId,
      'CitizenId': citizenId
    };
    final int addedCount = await db.insert('`GuardianRelations`', insertQuery);
    return addedCount == 1;
  }

  // Week API functions

  /// Get all weeks from a user with the Id [id]
  Future<List<WeekNameModel>> getWeekNames(String id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> res =
        await db.rawQuery('SELECT * FROM `Weeks` AS `w` JOIN `Users` AS `u` '
            "ON `w`.`GirafUserId`==`u`.`Id` WHERE `u`.Id == '$id'");
    return res
        .map((Map<String, dynamic> json) => WeekNameModel.fromDatabase(json))
        .toList();
  }

  /// Get a week base on
  /// [id] (User id)
  /// [year]
  /// [weekNumber]
  Future<WeekModel> getWeek(String id, int year, int weekNumber) async {
    final Database db = await database;
    final List<Map<String, dynamic>> res =
        await db.rawQuery('SELECT * FROM `Weeks` '
            "Where GirafUserIdId == '$id' AND "
            "`Year` == '$year' AND "
            "`WeekNumber` == '$weekNumber'");
    final Map<String, dynamic> weekModel = res[0];
    weekModel['Thumbnail'] =
        (await getPictogramID(res[0]['ThumbnailKey'])).toJson();
    return WeekModel.fromDatabase(weekModel);
  }

  /// Update a week with all the fields in the given [week]
  /// With the userid [id]
  /// Year [year]
  /// And Weeknumber [weekNumber]
  Future<WeekModel> updateWeek(
      String id, int year, int weekNumber, WeekModel week) async {
    final Database db = await database;
    await db.rawUpdate("UPDATE `Weeks` SET WeekYear = '${week.weekYear}', "
        "Name = '${week.name}', "
        "ThumbnailKey = '${week.thumbnail.id}', "
        "WeekNumber = '${week.weekNumber}' WHERE "
        "GirafUserId == '$id' AND "
        "WeekYear == '$year' AND "
        "WeekNumber == '$weekNumber'");
    return getWeek(id, year, weekNumber);
  }

  /// Delete a Week With the userid [id]
  /// Year [year]
  /// And Weeknumber [weekNumber]
  Future<bool> deleteWeek(String id, int year, int weekNumber) async {
    final Database db = await database;
    final int deleteCount = await db.rawDelete('DELETE FROM `Weeks` WHERE '
        "GirrafUserId == '$id' AND "
        "WeekYear == '$year' AND "
        "WeekNumber == '$weekNumber'");
    return 0 < deleteCount;
  }

  // Week Template API functions

  /// Get all weekTemplateNameModels
  Future<List<WeekTemplateNameModel>> getTemplateNames() async {
    final Database db = await database;
    final List<Map<String, dynamic>> res =
        await db.rawQuery('SELECT * FROM `WeekTemplates`');
    return res
        .map((Map<String, dynamic> json) =>
            WeekTemplateNameModel.fromDatabase(json))
        .toList();
  }

  /// Create a week template in the database from [template]
  Future<WeekTemplateModel> createTemplate(WeekTemplateModel template) async {
    final Database db = await database;
    final Map<String, dynamic> insertQuery = <String, dynamic>{
      'Name': template.name,
      'ThumbnailKey': template.thumbnail.id,
      'OnlineId': template.id ?? Uuid().v1().hashCode,
      'Department': template.departmentKey
    };
    await db.insert('WeekTemplates', insertQuery);
    return getTemplate(template.id);
  }

  /// get a template by its [id]
  Future<WeekTemplateModel> getTemplate(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> res =
        await db.rawQuery('SELECT * FROM `WeekTemplates` WHERE '
            "OnlineId == '$id'");
    final Map<String, dynamic> template = res[0];
    template['Thumbnail'] = getPictogramID(template['ThumbnailKey']);
    return WeekTemplateModel.fromDatabase(template);
  }

  /// Update a template with all the values from [template]
  Future<WeekTemplateModel> updateTemplate(WeekTemplateModel template) async {
    final Database db = await database;
    db.rawUpdate('UPDATE `WeekTemplates` SET '
        "Name = '${template.name}', "
        "ThumbnailKey = '${template.thumbnail.id}', "
        "Department = '${template.departmentKey}' WHERE "
        "OfflineId == '${template.id}'");
    return getTemplate(template.id);
  }

  /// Delete a template with the id [id]
  Future<bool> deleteTemplate(int id) async {
    final Database db = await database;
    final int deleteCount =
        await db.rawDelete('DELETE FROM `WeekTemplates` WHERE '
            "OfflineID =='$id'");
    return deleteCount > 0;
  }

  /// Gets the version of the currently running db
  Future<int> getCurrentDBVersion() async {
    final Database db = await database;
    return db.getVersion();
  }

  /// Force close the db
  Future<void> closeDb() async {
    final Database db = await database;
    await db.close();
  }
}
