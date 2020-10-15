import 'package:api_client/api/account_api.dart';
import 'package:api_client/api/department_api.dart';
import 'package:api_client/http/http_client.dart';
import 'package:api_client/api/pictogram_api.dart';
import 'package:api_client/api/activity_api.dart';
import 'package:api_client/api/status_api.dart';
import 'package:api_client/api/user_api.dart';
import 'package:api_client/api/week_api.dart';
import 'package:api_client/api/week_template_api.dart';
import 'package:api_client/offline_database/offline_db_handler.dart';
import 'package:api_client/persistence/persistence.dart';
import 'package:api_client/persistence/persistence_client.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Weekplanner API
class Api {
  /// Default constructor
  Api(this.baseUrl,
      [String tokenKey = 'token',
      Duration timeout = const Duration(seconds: 5)]) {
    final Persistence persist = PersistenceClient();
    OfflineDbHandler dbHandler;
    createDBHandler().then((OfflineDbHandler handler) => dbHandler = handler);
    account = AccountApi(
        HttpClient(
            baseUrl: '$baseUrl/v1',
            persist: persist,
            tokenKey: tokenKey,
            timeout: timeout),
        persist,
        dbHandler);
    status = StatusApi(HttpClient(
        baseUrl: '$baseUrl/v1/Status',
        persist: persist,
        tokenKey: tokenKey,
        timeout: timeout));
    department = DepartmentApi(HttpClient(
        baseUrl: '$baseUrl/v1/Department',
        persist: persist,
        tokenKey: tokenKey,
        timeout: timeout));
    week = WeekApi(
        HttpClient(
            baseUrl: '$baseUrl/v1/User',
            persist: persist,
            tokenKey: tokenKey,
            timeout: timeout),
        dbHandler);
    pictogram = PictogramApi(
        HttpClient(
            baseUrl: '$baseUrl/v1/Pictogram',
            persist: persist,
            tokenKey: tokenKey,
            timeout: timeout),
        dbHandler);
    activity = ActivityApi(
        HttpClient(
            baseUrl: '$baseUrl/v2/Activity',
            persist: persist,
            tokenKey: tokenKey,
            timeout: timeout),
        dbHandler);
    weekTemplate = WeekTemplateApi(
        HttpClient(
            baseUrl: '$baseUrl/v1/WeekTemplate',
            persist: persist,
            tokenKey: tokenKey,
            timeout: timeout),
        dbHandler);
    user = UserApi(
        HttpClient(
            baseUrl: '$baseUrl/v1/User',
            persist: persist,
            tokenKey: tokenKey,
            timeout: timeout),
        dbHandler);
  }

  Future<OfflineDbHandler> createDBHandler() async {
    return OfflineDbHandler(
        await openDatabase(join(await getDatabasesPath(), 'offlineGiraf')));
  }

  /// To access account endpoints
  AccountApi account;

  /// To access department endpoints
  DepartmentApi department;

  /// To access pictogram endpoints
  PictogramApi pictogram;

  /// To access activity endpoints
  ActivityApi activity;

  /// To access week endpoints
  WeekApi week;

  /// To access status endpoints
  StatusApi status;

  /// To access weekTemplate endpoints
  WeekTemplateApi weekTemplate;

  /// To access user endpoints
  UserApi user;

  /// The base of all requests.
  ///
  /// Example: if set to `http://google.com`, then a get request with url
  /// `/search` will resolve to `http://google.com/search`
  String baseUrl;

  /// Destroy the API
  void dispose() {}
}
