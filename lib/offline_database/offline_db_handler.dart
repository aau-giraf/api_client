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
import 'package:api_client/models/enums/role_enum.dart';
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
import 'package:api_client/models/weekday_model.dart';
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
    _database ??= await initializeDatabase();
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
    await deleteDatabase(join(await getDatabasesPath(), 'offlineGiraf'));
    return openDatabase(
        join(await getDatabasesPath(), 'offlineGiraf'),
        onCreate: (Database db, int version) => createTables(db),
        onUpgrade: (Database db, int oldVersion, int newVersion)
          => createTables(db),
        onDowngrade: (Database db, int oldVersion, int newVersion)
          => createTables(db),
        version: 1,
    );
  }

  ///Creates all of the tables in the DB
  Future<void> createTables(Database db) async {
    await db.transaction((Transaction txn) async {
      await txn.execute('''
          CREATE TABLE IF NOT EXISTS Settings (
          id integer NOT NULL PRIMARY KEY,
          orientation integer NOT NULL,
          completeMark integer NOT NULL,
          cancelMark integer NOT NULL,
          defaultTimer integer NOT NULL,
          timerSeconds integer DEFAULT NULL,
          activitiesCount integer DEFAULT NULL,
          theme integer NOT NULL,
          nrOfDaysToDisplay integer DEFAULT NULL,
          greyScale integer DEFAULT 0,
          lockTimerControl integer DEFAULT 0,
          pictogramText integer DEFAULT 0)
      ''');
      await txn.execute('''
          CREATE TABLE IF NOT EXISTS Users (
          id text NOT NULL PRIMARY KEY,
          role integer NOT NULL,
          roleName text DEFAULT NULL,
          username text DEFAULT NULL,
          displayName text NOT NULL,
          department integer DEFAULT NULL,
          password text NOT NULL,
          settingsId integer DEFAULT NULL,
          UNIQUE(username),
          CONSTRAINT FK_Users_Settings_SettingsKey
          FOREIGN KEY(settingsId)
          REFERENCES Settings(id) ON DELETE RESTRICT)
      ''');
      await txn.execute('''
          CREATE TABLE IF NOT EXISTS GuardianRelations (
          citizenId text NOT NULL,
          guardianId text NOT NULL,
          PRIMARY KEY(citizenId, guardianId),
          CONSTRAINT FK_GuardianRelations_Users_CitizenId
          FOREIGN KEY(citizenId)
          REFERENCES Users(id) ON DELETE CASCADE,
          CONSTRAINT FK_GuardianRelations_Users_GuardianId
          FOREIGN KEY(guardianId)
          REFERENCES Users(id) ON DELETE CASCADE)
      ''');
      await txn.execute('''
          CREATE TABLE IF NOT EXISTS WeekDayColors (
          id	integer NOT NULL PRIMARY KEY,
          day integer NOT NULL,
          hexColor	text COLLATE BINARY,
          settingsId integer NOT NULL,
          CONSTRAINT FK_WeekDayColors_Settings_SettingsId
          FOREIGN KEY(settingsId)
          REFERENCES Settings(id) ON DELETE CASCADE)
      ''');
      
      
      await txn.execute('''
          CREATE TABLE IF NOT EXISTS Pictograms (
          id integer NOT NULL PRIMARY KEY AUTOINCREMENT,
          accessLevel integer NOT NULL,
          lastEdit datetime NOT NULL,
          title text NOT NULL,
          imageHash	text COLLATE BINARY,
          onlineId integer NOT NULL,
          UNIQUE(title, onlineId))
      ''');
      await txn.execute('''
          CREATE TABLE IF NOT EXISTS WeekTemplates (
          id	integer NOT NULL PRIMARY KEY AUTOINCREMENT,
          name	text COLLATE BINARY,
          thumbnailKey	integer NOT NULL,
          onlineId integer NOT NULL,
          department integer,
          CONSTRAINT FK_WeekTemplates_Pictograms_ThumbnailKey
          FOREIGN KEY(thumbnailKey)
          REFERENCES Pictograms(onlineId) ON DELETE CASCADE)
      ''');
      await txn.execute('''
          CREATE TABLE IF NOT EXISTS Weeks (
          id	integer NOT NULL PRIMARY KEY AUTOINCREMENT,
          girafUserId text NOT NULL,
          name	text COLLATE BINARY,
          thumbnailKey integer NOT NULL,
          weekNumber	integer NOT NULL,
          weekYear	integer NOT NULL,
          CONSTRAINT FK_Weeks_AspNetUsers_GirafUserId
          FOREIGN KEY(girafUserId)
          REFERENCES Users(id) ON DELETE CASCADE,
          CONSTRAINT FK_Weeks_Pictograms_ThumbnailKey
          FOREIGN KEY(thumbnailKey)
          REFERENCES Pictograms(onlineId) ON DELETE CASCADE)
      ''');
      await txn.execute('''
          CREATE TABLE IF NOT EXISTS Weekdays (
          id	integer NOT NULL PRIMARY KEY AUTOINCREMENT,
          day integer NOT NULL,
          weekId	integer DEFAULT NULL,
          weekTemplateId	integer DEFAULT NULL,
          CONSTRAINT FK_Weekdays_WeekTemplates_WeekTemplateId
          FOREIGN KEY(weekTemplateId)
          REFERENCES WeekTemplates(onlineId) ON DELETE CASCADE,
          CONSTRAINT FK_Weekdays_Weeks_WeekId
          FOREIGN KEY(weekId)
          REFERENCES Weeks(id) ON DELETE CASCADE)
      ''');
      await txn.execute('''
          CREATE TABLE IF NOT EXISTS Timers (
          key integer NOT NULL PRIMARY KEY AUTOINCREMENT,
          startTime integer NOT NULL,
          progress	integer NOT NULL,
          fullLength	integer NOT NULL,
          paused	integer NOT NULL)
      ''');
      await txn.execute('''
          CREATE TABLE IF NOT EXISTS Activities (
          key integer NOT NULL PRIMARY KEY AUTOINCREMENT,
          orderValue integer NOT NULL,
          otherKey	integer NOT NULL,
          state integer NOT NULL,
          timerKey	integer DEFAULT NULL,
          isChoiceBoard integer NOT NULL DEFAULT 0,
          CONSTRAINT FK_Activities_Timers_TimerKey
          FOREIGN KEY(timerKey)
          REFERENCES Timers(key) ON DELETE SET NULL,
          CONSTRAINT FK_Activities_Weekdays_OtherKey
          FOREIGN KEY(otherKey)
          REFERENCES Weekdays(id) ON DELETE CASCADE)
      ''');
      await txn.execute('''
          CREATE TABLE IF NOT EXISTS PictogramRelations (
          activityId	integer NOT NULL,
          pictogramId integer NOT NULL,
          PRIMARY KEY(activityId,pictogramId),
          CONSTRAINT FK_PictogramRelations_Activities_ActivityId
          FOREIGN KEY(activityId)
          REFERENCES Activities(key) ON DELETE CASCADE,
          CONSTRAINT FK_PictogramRelations_Pictograms_PictogramId
          FOREIGN KEY(pictogramId)
          REFERENCES Pictograms(onlineId) ON DELETE CASCADE)
      ''');
      await txn.execute('''
          CREATE TABLE IF NOT EXISTS FailedOnlineTransactions (
          type text NOT NULL,
          url text NOT NULL,
          body text,
          tableAffected text,
          tempId text)
      ''');
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
      'type': type,
      'url': baseUrl + url,
      'body': body.toString(),
      'tableAffected': tableAffected,
      'tempId': tempId
    };
    db.insert('FailedOnlineTransactions', insertQuery);
  }

  /// Retry sending the failed changes to the online database
  Future<void> retryFailedTransactions() async {
    final Database db = await database;

    final List<Map<String, dynamic>> dbRes =
        await db.rawQuery('SELECT * FROM FailedOnlineTransactions');
    if (dbRes.isNotEmpty) {
      final Http _http = getHttpObject();
      for (Map<String, dynamic> transaction in dbRes) {
        switch (transaction['type']) {
          case 'DELETE':
            _http.delete(transaction['url']).listen((Response res) async {
              if (res.success()) {
                await removeFailedTransaction(transaction);
              }
            }).onError((Object error) {});
            break;
          case 'POST':
            _http
                .post(transaction['url'], transaction['body'])
                .listen((Response res) async {
              if (res.success()) {
                await removeFailedTransaction(transaction);
                await updateIdInOfflineDb(
                    res.json['data'],
                    transaction['tableAffected'],
                    int.tryParse(transaction['tempId']));
              }
            }).onError((Object error) {});
            break;
          case 'PATCH':
            _http
                .patch(transaction['url'], transaction['body'])
                .listen((Response res) async {
              if (res.success()) {
                await removeFailedTransaction(transaction);
              }
            }).onError((Object error) {});
            break;
          case 'PUT':
            _http
                .put(transaction['url'], transaction['body'])
                .listen((Response res) async {
              if (res.success()) {
                await removeFailedTransaction(transaction);
              }
            }).onError((Object error) {});
            break;
          default:
            throw const HttpException('invalid request type');
        }
      }
    }
  }

  /// Exists to be able to override the http used for retry failed transactions
  Http getHttpObject() {
    return HttpClient(baseUrl: '', persist: PersistenceClient());
  }

  /// Update an Id in the offline DB with a new one from the online database,
  /// once the online is done creating them. The [json] contains the key
  /// [table] is the table to be changed
  /// [tempId] is the id assigned when the object was created offline
  Future<void> updateIdInOfflineDb(
      Map<String, dynamic> json, String table, int tempId) async {
    switch (table) {
      case 'Users':
        replaceTempIdUsers(tempId, int.tryParse(json['id']));
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
  Future<void> replaceTempIdUsers(int oldId, int newId) async {
    final Database db = await database;
    db.rawUpdate('UPDATE Users SET id = $newId WHERE id == $oldId');
    db.rawUpdate('UPDATE GuardianRelations SET citizenId = $newId '
        'WHERE citizenId == $oldId');
    db.rawUpdate('UPDATE GuardianRelations SET guardianId = $newId '
        'WHERE guardianId == $oldId');
    db.rawUpdate('UPDATE Weeks SET girafUserId = $newId '
        'WHERE girafUserId == $oldId');
  }

  /// Replace the id of a Pictogram
  /// Should be called to replace the id given by this class with the one in the
  /// online database, such that they are synchonized
  Future<void> replaceTempIdPictogram(int oldId, int newId) async {
    final Database db = await database;
    db.rawUpdate('UPDATE Pictograms SET id = $newId '
        'WHERE id == $oldId');
    db.rawUpdate('UPDATE WeekTemplates SET thumbnailKey = $newId '
        'WHERE thumbnailKey == $oldId');
    db.rawUpdate('UPDATE Weeks SET thumbnailKey = $newId '
        'WHERE thumbnailKey == $oldId');
    db.rawUpdate('UPDATE PictogramRelations SET pictogramId = $newId '
        'WHERE pictogramId == $oldId');
  }

  /// Replace the id of a Pictogram
  /// Should be called to replace the id given by this class with the one in the
  /// online database, such that they are synchonized
  Future<void> replaceTempIdWeekTemplate(int oldId, int newId) async {
    final Database db = await database;
    db.rawUpdate('UPDATE WeekTemplates SET onlineId = $newId '
        'Where onlineId == $oldId');
    db.rawUpdate('UPDATE Weekdays SET weekTemplateId = $newId '
        'Where weekTemplateId == $oldId');
  }

  /// Remove a previously failed transaction from the
  /// offline database when it succeeds
  Future<void> removeFailedTransaction(Map<String, dynamic> transaction) async {
    final Database db = await database;
    await db.rawDelete('DELETE FROM FailedOnlineTransactions WHERE '
        'type == ${transaction['type']} AND '
        'url == ${transaction['url']} AND '
        'body == ${transaction['body']} AND '
        'tableAffected == ${transaction['tableAffected']} AND '
        'tempId == ${transaction['tempId']}');
  }

  // Account API functions
  /// Returns [true] if [password] matches the password saved for [username]
  Future<bool> login(String username, String password) async {
    final Database db = await database;
    final List<Map<String, dynamic>> res = await db
        .rawQuery('SELECT password FROM Users WHERE username == $username');
    return sha512.convert(utf8.encode(password)).toString() ==
        res[0]['password'];
  }

  /// register an account for a user
  Future<GirafUserModel> registerAccount(Map<String, dynamic> body) async {
    final Database db = await database;
    final List<Map<String, dynamic>> count = await db.rawQuery(
        'SELECT * FROM Users WHERE username == ${body['username']}');

    if (count.isNotEmpty) {
      // TODO(Tilasair): better exceptions
      throw Exception('Username already exists');
    }

    final Map<String, dynamic> settings = <String, dynamic>{
      'activitiesCount': 0,
      'cancelMark': CancelMark.Cross.index,
      'completeMark': CompleteMark.Checkmark.index,
      'defaultTimer': DefaultTimer.PieChart.index,
      'greyScale': 0, //false
      'nrOfDaysToDisplay': 7,
      'orientation': Orientation.portrait.index,
      'theme': GirafTheme.GirafYellow.index,
      'timerSeconds': 900,
      'lockTimerControl': 0, //false
      'pictogramText': 0 //false
    };
    // TODO(Tilasair): Make the settings a transaction
    await db.insert('Settings', settings);
    final List<Map<String, dynamic>> settingsIdRes =
        await db.rawQuery('SELECT id FROM Settings WHERE id NOT IN '
            '(SELECT settingsId FROM Users)');
    final int settingsId = settingsIdRes[0]['id'];
    await db.insert('WeekDayColors', <String, dynamic>{
      'day': Weekday.Monday.index,
      'hexColor': '#08a045',
      'settingsId': settingsId
    });
    await db.insert('WeekDayColors', <String, dynamic>{
      'day': Weekday.Tuesday.index,
      'hexColor': '#540d6e',
      'settingsId': settingsId
    });
    await db.insert('WeekDayColors', <String, dynamic>{
      'day': Weekday.Wednesday.index,
      'hexColor': '#f77f00',
      'settingsId': settingsId
    });
    await db.insert('WeekDayColors', <String, dynamic>{
      'day': Weekday.Thursday.index,
      'hexColor': '#004777',
      'settingsId': settingsId
    });
    await db.insert('WeekDayColors', <String, dynamic>{
      'day': Weekday.Friday.index,
      'hexColor': '#f9c80e',
      'settingsId': settingsId
    });
    await db.insert('WeekDayColors', <String, dynamic>{
      'day': Weekday.Saturday.index,
      'hexColor': '#db2b39',
      'settingsId': settingsId
    });
    await db.insert('WeekDayColors', <String, dynamic>{
      'day': Weekday.Sunday.index,
      'hexColor': '#ffffff',
      'settingsId': settingsId
    });
    int roleID;
    switch (body['role']) {
      case 'Citizen':
        roleID = 1;
        break;
      case 'Department':
        roleID = 2;
        break;
      case 'Guardian':
        roleID = 3;
        break;
      case 'SuperUser':
        roleID = 4;
        break;
      case 'Trustee':
        roleID = 5;
        break;
      default:
        roleID = 0;
    }
    final Map<String, dynamic> insertQuery = <String, dynamic>{
      'id': Uuid().v1(),
      'role': roleID,
      'roleName': body['role'],
      'username': body['username'],
      'displayName': body['displayName'],
      'department': body['department'],
      'password': sha512.convert(utf8.encode(body['password'])).toString(),
      'settingsId': settingsId
    };
    await db.insert('Users', insertQuery);
    final List<Map<String, dynamic>> res = await db.rawQuery(
        'SELECT * FROM Users WHERE username == ${body['username']}');
    return GirafUserModel.fromJson(res[0]);
  }

  /// Do not call this function without ensuring that the password is
  /// successfully changed online
  /// change a password of a user with id [id] to [newPassword]
  Future<bool> changePassword(String id, String newPassword) async {
    final Database db = await database;
    final String encryptedPassword =
        sha512.convert(utf8.encode(newPassword)).toString();
    final int rowsChanged = await db.rawUpdate(
        'UPDATE Users SET password = $encryptedPassword WHERE id == $id');
    return rowsChanged == 1;
  }

  /// Delete a user from the offline database
  Future<bool> deleteAccount(String id) async {
    final Database db = await database;
    final int res =
        await db.rawDelete('DELETE FROM Users WHERE id == $id');
    return res == 1;
  }

  // Activity API functions
  /// Add an activity to DB
  Future<ActivityModel> addActivity(ActivityModel activity, String userId,
      String weekplanName, int weekYear, int weekNumber, Weekday weekDay,
      {TimerModel timer}) async {
    final Database db = await database;
    final List<Map<String, dynamic>> dbWeek =
        await db.rawQuery('SELECT * FROM Weeks WHERE '
            'girafUserId == $userId AND '
            'weekYear == $weekYear AND '
            'weekNumber == $weekNumber');
    final List<Map<String, dynamic>> dbDay =
        await db.rawQuery('SELECT * FROM Weekdays WHERE '
            'day == ${weekDay.index} AND '
            'weekId == ${dbWeek[0]['id']}');

    final Map<String, dynamic> insertActivityQuery = <String, dynamic>{
      'key': activity.id,
      'order': activity.order,
      'otherKey': dbDay[0]['id'],
      'state': activity.state.index,
      'isChoiceBoard': activity.isChoiceBoard ? 1 : 0,
    };
    Map<String, dynamic> insertTimerQuery;
    if (activity.timer != null) {
      insertActivityQuery['TimerKey'] = activity.timer.key;
      insertTimerQuery = <String, dynamic>{
        'key': activity.timer.key,
        'startTime': activity.timer.startTime.millisecondsSinceEpoch,
        'progress': activity.timer.progress,
        'fullLength': activity.timer.fullLength,
        'paused': activity.timer.paused ? 1 : 0,
      };
    }

    db.transaction((Transaction txn) async {
      for (PictogramModel pictogram in activity.pictograms) {
        await txn.insert('PictogramRelations', <String, dynamic>{
          'activityId': activity.id,
          'pictogramId': pictogram.id
        });
      }
    });
    await db.insert('Activities', insertActivityQuery);
    if (insertTimerQuery != null) {
      await db.insert('Timers', insertTimerQuery);
    }
    return _getActivity(activity.id, db);
  }

  Future<ActivityModel> _getActivity(int key, Database db) async {
    final List<Map<String, dynamic>> listResult =
        await db.rawQuery('SELECT * FROM Activities WHERE key == $key');
    if (listResult.isEmpty) {
      return null;
    }
    final Map<String, dynamic> result = listResult[0];
    TimerModel timerModel;
    if (result != null && result['timerKey'] != null) {
      timerModel = await _getTimer(result['timerKey']);
    }
    final List<PictogramModel> pictoList = await _getActivityPictograms(key);

    return ActivityModel.fromDatabase(result,
        timer: timerModel, pictograms: pictoList);
  }

  Future<List<PictogramModel>> _getActivityPictograms(int activityKey) async {
    final Database db = await database;
    final List<Map<String, dynamic>> res = await db.rawQuery(
        'SELECT * FROM Pictograms '
        'WHERE onlineId == (SELECT pictogramId FROM PictogramRelations '
        'WHERE activityId == $activityKey)');
    final List<PictogramModel> result = <PictogramModel>[];
    for (Map<String, dynamic> pictogram in res) {
      result.add(PictogramModel.fromDatabase(pictogram));
    }
    return result;
  }

  Future<TimerModel> _getTimer(int key) async {
    final Database db = await database;
    final List<Map<String, dynamic>> res =
        await db.rawQuery('SELECT * FROM Timers WHERE key == $key');
    return TimerModel.fromDatabase(res[0]);
  }

  ///Update an [activity] from its id
  Future<ActivityModel> updateActivity(
      ActivityModel activity, String userId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> res = await db
        .rawQuery('SELECT * FROM Activities WHERE key == ${activity.id}');
    if (activity.timer == null) {
      if (res.isNotEmpty) {
        await db.rawDelete(
            'DELETE FROM Timers WHERE key == ${res[0]['timerKey']}');
      }
      await db.rawUpdate('UPDATE Activities SET '
          'order = ${activity.order}, '
          'state = ${activity.state.index}, '
          'isChoiceBoard = ${activity.isChoiceBoard} '
          'WHERE key == ${activity.id}');
    } else {
      final int timerKey = activity.timer.key ?? Uuid().v1().hashCode;
      await db.rawUpdate('UPDATE Activities SET '
          'order = ${activity.order}, '
          'state = ${activity.state.index}, '
          'timerKey = $timerKey, '
          'isChoiceBoard = ${activity.isChoiceBoard} '
          'WHERE key == ${activity.id}');
      if (res[0]['timerKey'] == null) {
        final Map<String, dynamic> insertTimerQuery = <String, dynamic>{
          'key': timerKey,
          'startTime': activity.timer.startTime.millisecondsSinceEpoch,
          'progress': activity.timer.progress,
          'fullLength': activity.timer.fullLength,
          'paused': activity.timer.paused ? 1 : 0,
        };
        db.insert('Timers', insertTimerQuery);
      } else {
        await db.rawUpdate('UPDATE Timers SET '
          'startTime = ${activity.timer.startTime.millisecondsSinceEpoch}, '
          'progress = ${activity.timer.progress}, '
          'fullLength = ${activity.timer.fullLength}, '
          'paused = ${activity.timer.paused} '
          'WHERE key == ${activity.timer.key}');
      }
    }
    db.transaction((Transaction txn) async {
      await txn.rawDelete('DELETE FROM PictogramRelations '
          'WHERE activityId = ${activity.id}');
      for (PictogramModel pictogram in activity.pictograms) {
        await txn.insert('PictogramRelations', <String, dynamic>{
          'activityId': activity.id,
          'pictogramId': pictogram.id
        });
      }
    });
    return _getActivity(activity.id, db);
  }

  ///Delete an activity with the id [activityId]
  Future<bool> deleteActivity(int activityId, String userId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> res = await db.rawQuery(
        'SELECT timerKey FROM Activities WHERE key == $activityId');
    final int timerKey = res[0]['TimerKey'];
    final int activityChanged = await db
        .rawDelete('DELETE FROM Activities WHERE key == $activityId');
    int timersChanged;
    if (timerKey != null) {
      timersChanged =
          await db.rawDelete('DELETE FROM Timers WHERE key == $timerKey');
    } else {
      timersChanged = 1;
    }
    final int relationsChanged = await db.rawDelete(
        'DELETE FROM PictogramRelations WHERE activityId == $activityId');
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
        await db.rawQuery('SELECT * FROM Pictograms '
            'WHERE title LIKE %$query%');
    final List<PictogramModel> allPictograms = <PictogramModel>[];
    for (Map<String, dynamic> pictogram in res) {
      allPictograms.add(PictogramModel.fromDatabase(pictogram));
    }
    final List<List<PictogramModel>> possibleResults = <List<PictogramModel>>[];
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
        await db.rawQuery('SELECT * FROM Pictograms WHERE onlineId == $id');
    return PictogramModel.fromDatabase(res[0]);
  }

  ///Add a pictogram to the offline database
  Future<PictogramModel> createPictogram(PictogramModel pictogram) async {
    final Database db = await database;
    final Map<String, dynamic> insertQuery = <String, dynamic>{
      'onlineId': pictogram.id ?? Uuid().v1().hashCode,
      'accessLevel': pictogram.accessLevel.index,
      'lastEdit': pictogram.lastEdit.toIso8601String(),
      'title': pictogram.title,
      'imageHash': pictogram.imageHash,
    };
    await db.insert('Pictograms', insertQuery);
    return getPictogramID(insertQuery['onlineId']);
  }

  ///Update a given pictogram
  Future<PictogramModel> updatePictogram(PictogramModel pictogram) async {
    final Database db = await database;
    await db.rawUpdate('UPDATE Pictograms SET '
        'accessLevel = ${pictogram.accessLevel.index}, '
        'lastEdit = ${pictogram.lastEdit}, '
        'title = ${pictogram.title}, '
        'imageHash = ${pictogram.imageHash} '
        'WHERE onlineId == ${pictogram.id}');
    return getPictogramID(pictogram.id);
  }

  /// Delete a pictogram with the id [id]
  Future<bool> deletePictogram(int id) async {
    final Database db = await database;
    final int pictogramsDeleted =
        await db.rawDelete('DELETE FROM Pictograms WHERE onlineId == $id');
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
        await db.rawQuery('SELECT * FROM Pictograms WHERE onlineId == $id');
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
        await db.rawQuery('SELECT * FROM Users WHERE id == $id');
    return GirafUserModel.fromJson(res[0]);
  }

  /// Return the ID of a user through its username
  Future<String> getUserId(String userName) async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> id = await db
          .rawQuery('SELECT * FROM Users WHERE username == $userName');
      return id[0]['id'];
    } catch (error) {
      return null;
    }
  }

  /// Return the role of a user through its username
  Future<int> getUserRole(String username) async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> users = await db
          .rawQuery('SELECT * FROM Users WHERE username == $username');
      return users[0]['role'];
    } catch (error) {
      return Role.Unknown.index;
    }
  }

  /// Inserts the user.
  ///
  /// This method should only be called on login,
  /// when receiving user data from the server.
  Future<GirafUserModel> insertUser(GirafUserModel user) async {
    final Database db = await database;
    await db.insert('Users', <String, dynamic>{
      'id': user.id,
      'role': user.role.index,
      'roleName': user.roleName,
      'username': user.username,
      'displayName': user.displayName,
      'department': user.department,
      'password': 'password'
    });

    return getUser(user.id);
  }

  /// Update a user based on [user.id] with the values from [user]
  Future<GirafUserModel> updateUser(GirafUserModel user) async {
    final Database db = await database;
    await db.rawUpdate('UPDATE Users SET '
        'role = ${user.role.index}, '
        'roleName = ${user.roleName}, '
        'username = ${user.username}, '
        'displayName = ${user.displayName}, '
        'department = ${user.department} '
        'WHERE id == ${user.id}');
    return getUser(user.id);
  }

  /// Get a the relevant settings for a user with the id: [id]
  Future<SettingsModel> getUserSettings(String id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> resSettings =
        await db.rawQuery('SELECT * FROM Settings WHERE '
            'id == (SELECT settingsId FROM Users WHERE id == $id)');
    final List<Map<String, dynamic>> resWeekdayColors =
        await db.rawQuery('SELECT * FROM WeekDayColors WHERE '
            'settingsId == ${resSettings[0]['id']}');
    return SettingsModel.fromDatabase(resSettings[0], resWeekdayColors);
  }

  /// Insert settings for the specified user
  Future<SettingsModel> insertUserSettings(
      String userId, SettingsModel settings) async {
    final Database db = await database;
    final int settingsId = await db.insert('Settings', <String, dynamic>{
      'activitiesCount': settings.activitiesCount,
      'cancelMark': settings.cancelMark.index,
      'completeMark': settings.completeMark.index,
      'defaultTimer': settings.defaultTimer.index,
      'greyScale': settings.greyscale,
      'nrOfDaysToDisplay': settings.nrOfDaysToDisplay,
      'orientation': settings.orientation.index,
      'theme': settings.theme.index,
      'timerSeconds': settings.timerSeconds,
      'lockTimerControl': settings.lockTimerControl,
      'pictogramText': settings.pictogramText
    });

    /* WeekDayColors is a list in SettingsModel,
     * which means that they have to be saved in its own table */
    for (WeekdayColorModel dayColor in settings.weekDayColors) {
      final int day = dayColor.day.index;
      db.insert('WeekDayColors', <String, dynamic>{
        'hexColor': dayColor.hexColor,
        'day': day,
        'settingsId': settingsId
      });
    }

    // This will update the settingsId in the user tuple
    db.update('Users', <String, dynamic>{
      'settingsId': settingsId
    }, where: 'id = $userId');

    return getUserSettings(userId);
  }

  /// Update the settings for a Girafuser with the id: [id]
  Future<bool> updateUserSettings(
      String id, SettingsModel settings) async {
    final Database db = await database;
    final List<Map<String, dynamic>> res =
        await db.rawQuery('SELECT settingsId FROM Users WHERE id == $id');
    final String settingsId = res[0]['settingsId'].toString();
    db.rawUpdate('UPDATE Settings SET '
        'activitiesCount = ${settings.activitiesCount}, '
        'cancelMark = ${settings.cancelMark.index}, '
        'completeMark = ${settings.completeMark.index}, '
        'defaultTimer = ${settings.defaultTimer.index}, '
        'greyScale = ${settings.greyscale}, '
        'nrOfDaysToDisplay = ${settings.nrOfDaysToDisplay}, '
        'orientation = ${settings.orientation.index}, '
        'theme = ${settings.theme.index}, '
        'timerSeconds = ${settings.timerSeconds}, '
        'lockTimerControl = ${settings.lockTimerControl}, '
        'pictogramText = ${settings.pictogramText} '
        'WHERE id = $settingsId');
    for (WeekdayColorModel dayColor in settings.weekDayColors) {
      final int day = dayColor.day.index;
      db.rawUpdate('UPDATE WeekDayColors SET hexColor = ${dayColor.hexColor} '
          'WHERE settingsId == $settingsId AND day == $day');
    }
    return true;
  }

  /// Delete a users icon. as users do not have an icon,
  /// this is not yet implemented
  Future<bool> deleteUserIcon(String id) {
    throw UnimplementedError();
  }

  /// Get a users icon. as users do not have an icon,
  /// this is not yet implemented
  Future<Image> getUserIcon(String id) {
    throw UnimplementedError();
  }

  /// Update a users icon. as users do not have an icon,
  /// this is not yet implemented
  Future<bool> updateUserIcon() {
    throw UnimplementedError();
  }
  Future<Image> insertUserIcon(String id, Image icon){
    throw UnimplementedError();
  }

  /// Return list of citizens from database based on guardian id
  Future<List<DisplayNameModel>> getCitizens(String id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> res =
        await db.rawQuery('SELECT * FROM Users AS U JOIN '
            'GuardianRelations AS GR ON U.id == GR.citizenId '
            'WHERE GR.guardianId == $id');
    return res
        .map<DisplayNameModel>((Map<String, dynamic> citizenJson) =>
            DisplayNameModel.fromDatabase(citizenJson))
        .toList();
  }

  /// Return list of guardians from database based on citizen id
  Future<List<DisplayNameModel>> getGuardians(String id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> res =
        await db.rawQuery('SELECT * FROM Users AS U JOIN '
            'GuardianRelations AS GR ON U.id == GR.guardianId '
            'WHERE GR.citizenId == $id');
    return res
        .map<DisplayNameModel>((Map<String, dynamic> citizenJson) =>
            DisplayNameModel.fromDatabase(citizenJson))
        .toList();
  }

  /// Add a [guardianId] to a [citizenId]
  Future<bool> addCitizenToGuardian(String guardianId, String citizenId) async {
    final Database db = await database;
    final Map<String, dynamic> insertQuery = <String, dynamic>{
      'guardianId': guardianId,
      'citizenId': citizenId
    };
    final int addedCount = await db.insert('GuardianRelations', insertQuery);
    return addedCount == 1;
  }

  // Week API functions

  /// Get all weeks from a user with the Id [id]
  Future<List<WeekNameModel>> getWeekNames(String id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> res =
        await db.rawQuery('SELECT * FROM Weeks AS W JOIN Users AS U '
            'ON W.girafUserId == U.id WHERE U.id == $id');
    return res
        .map((Map<String, dynamic> json) => WeekNameModel.fromDatabase(json))
        .toList();
  }

  /// Get a week based on
  /// [id] (User id)
  /// [year]
  /// [weekNumber]
  Future<WeekModel> getWeek(String id, int year, int weekNumber) async {
    final Database db = await database;
    final List<Map<String, dynamic>> res =
        await db.rawQuery('SELECT * FROM Weeks WHERE '
            'girafUserId == $id AND '
            'weekYear == $year AND '
            'weekNumber == $weekNumber');
    final Map<String, dynamic> weekModel = Map<String, dynamic>.from(res[0]);
    weekModel['thumbnail'] =
        (await getPictogramID(res[0]['thumbnailKey'])).toJson();
    final int weekId = res.single['id'];
    final List<Map<String, dynamic>> weekDaysFromDb = await db
        .rawQuery('SELECT * FROM Weekdays WHERE weekId == $weekId');
    final List<Map<String, dynamic>> weekDays = <Map<String, dynamic>>[];
    for (Map<String, dynamic> day in weekDaysFromDb) {
      final List<Map<String, dynamic>> activityFromDb =
          await db.rawQuery('SELECT * FROM Activities WHERE '
              'otherKey == ${day['id']}');
      final Map<String, dynamic> dayRes = <String, dynamic>{
        'day': day['day'],
        'id': day['id'],
        'activities': List<Map<String, dynamic>>.from(activityFromDb)
      };
      weekDays.add(dayRes);
    }
    weekModel['days'] = List<Map<String, dynamic>>.from(weekDays);
    return WeekModel.fromDatabase(weekModel);
  }

  /// Update a week with all the fields in the given [week]
  /// With the userid [id]
  /// Year [year]
  /// And Weeknumber [weekNumber]
  Future<WeekModel> updateWeek(
      String id, int year, int weekNumber, WeekModel week) async {
    final Database db = await database;
    final List<Map<String, dynamic>> dbWeek =
        await db.rawQuery('SELECT * FROM Weeks WHERE '
            'girafUserId == $id AND '
            'weekYear == $year AND '
            'weekNumber == $weekNumber');
    if (dbWeek.isEmpty) {
      _createWeek(db, week, id);
    }
    await db.rawUpdate('UPDATE Weeks SET '
        'weekYear = ${week.weekYear}, '
        'name = ${week.name}, '
        'thumbnailKey = ${week.thumbnail.id}, '
        'weekNumber = ${week.weekNumber} WHERE '
        'girafUserId == $id AND '
        'weekYear == $year AND '
        'weekNumber == $weekNumber');
    return getWeek(id, year, weekNumber);
  }

  Future<void> _createWeek(Database db, WeekModel week, String id) async {
    final Map<String, dynamic> insertQuery = <String, dynamic>{
      'name': week.name,
      'thumbnailKey': week.thumbnail.id,
      'weekNumber': week.weekNumber,
      'girafUserId': id,
      'weekYear': week.weekYear
    };
    final int weekId = await db.insert('Weeks', insertQuery);
    for (WeekdayModel day in week.days) {
      await _insertWeekday(weekId, day, db, id, week);
    }
  }

  Future<void> _insertWeekday(int weekId, WeekdayModel day, Database db,
      String userId, WeekModel week) async {
    final Map<String, dynamic> insertQuery = <String, dynamic>{
      'day': day.day.index,
      'weekId': weekId
    };
    db.insert('Weekdays', insertQuery);
    if (day.activities != null) {
      for (ActivityModel activity in day.activities) {
        if (_getActivity(activity.id, db) == null) {
          addActivity(activity, userId, week.name, week.weekYear,
              week.weekNumber, day.day);
        } else {
          updateActivity(activity, userId);
        }
      }
    }
  }

  /// Delete a Week With the userid [id]
  /// Year [year]
  /// And Weeknumber [weekNumber]
  Future<bool> deleteWeek(String id, int year, int weekNumber) async {
    final Database db = await database;
    final List<Map<String, dynamic>> weekRes =
        await db.rawQuery('SELECT * FROM Weeks WHERE '
            'girafUserId == $id AND '
            'weekYear == $year AND '
            'weekNumber == $weekNumber');
    final List<Map<String, dynamic>> deleteDays =
        await db.rawQuery('SELECT * FROM Weekdays WHERE '
            'weekId == ${weekRes[0]['id']}');
    bool allDaysDeleted = true;
    for (Map<String, dynamic> day in deleteDays) {
      if (!(await _deleteWeekDay(id, day['id'], db))) {
        allDaysDeleted = false;
      }
    }
    final int deleteCount = await db.rawDelete('DELETE FROM Weeks WHERE '
        'girafUserId == $id AND '
        'weekYear == $year AND '
        'weekNumber == $weekNumber');

    return 0 < deleteCount && allDaysDeleted;
  }

  Future<bool> _deleteWeekDay(String userId, int weekDayId, Database db) async {
    final List<Map<String, dynamic>> deleteActivities = await db.rawQuery(
        'SELECT * FROM Activities WHERE otherKey == $weekDayId');
    bool activitiesDeleted = true;
    for (Map<String, dynamic> activity in deleteActivities) {
      if (!(await deleteActivity(activity['key'], userId))) {
        activitiesDeleted = false;
      }
    }
    final int daysDeleted = await db.rawDelete('DELETE FROM Weekdays WHERE '
        'id == $weekDayId');
    return daysDeleted == deleteActivities.length && activitiesDeleted;
  }

  // Week Template API functions

  /// Get all weekTemplateNameModels
  Future<List<WeekTemplateNameModel>> getTemplateNames() async {
    final Database db = await database;
    final List<Map<String, dynamic>> res =
        await db.rawQuery('SELECT * FROM WeekTemplates');
    final List<WeekTemplateNameModel> weekTemplates = <WeekTemplateNameModel>[];
    for (Map<String, dynamic> result in res) {
      weekTemplates.add(WeekTemplateNameModel.fromDatabase(result));
    }
    return weekTemplates;
  }

  /// Create a week template in the database from [template]
  Future<WeekTemplateModel> createTemplate(WeekTemplateModel template) async {
    final Database db = await database;
    final Map<String, dynamic> insertQuery = <String, dynamic>{
      'name': template.name,
      'thumbnailKey': template.thumbnail.id,
      'onlineId': template.id ?? Uuid().v1().hashCode,
      'department': template.departmentKey
    };
    await db.insert('WeekTemplates', insertQuery);
    return getTemplate(template.id);
  }

  /// Get a template by its [id]
  Future<WeekTemplateModel> getTemplate(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> res =
        await db.rawQuery('SELECT * FROM WeekTemplates WHERE '
            'onlineId == $id');
    final Map<String, dynamic> tempRes = res[0];
    // get the first record
    final Map<String, dynamic> template = Map<String, dynamic>.from(tempRes);
    template['thumbnail'] =
        (await getPictogramID(template['thumbnailKey'])).toJson();
    return WeekTemplateModel.fromDatabase(template);
  }

  /// Update a template with all the values from [template]
  Future<WeekTemplateModel> updateTemplate(WeekTemplateModel template) async {
    final Database db = await database;
    db.rawUpdate('UPDATE WeekTemplates SET '
        'name = ${template.name}, '
        'thumbnailKey = ${template.thumbnail.id}, '
        'department = ${template.departmentKey} WHERE '
        'id == ${template.id}');
    final List<Map<String, dynamic>> templateRes =
        await db.rawQuery('SELECT OnlineId FROM WeekTemplates WHERE '
            'id == ${template.id} AND name == ${template.name}');
    return getTemplate(templateRes[0]['onlineId']);
  }

  /// Delete a template with the id [id]
  Future<bool> deleteTemplate(int id) async {
    final Database db = await database;
    final int deleteCount =
        await db.rawDelete('DELETE FROM WeekTemplates WHERE '
        'onlineID == $id');
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
