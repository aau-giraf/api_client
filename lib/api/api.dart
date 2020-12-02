import 'package:api_client/api/account_api.dart';
import 'package:api_client/api/alternate_name_api.dart';
import 'package:api_client/api/department_api.dart';
import 'package:api_client/http/http_client.dart';
import 'package:api_client/api/pictogram_api.dart';
import 'package:api_client/api/activity_api.dart';
import 'package:api_client/api/status_api.dart';
import 'package:api_client/api/user_api.dart';
import 'package:api_client/api/week_api.dart';
import 'package:api_client/api/week_template_api.dart';
import 'package:api_client/persistence/persistence.dart';
import 'package:api_client/persistence/persistence_client.dart';

/// Weekplanner API
class Api {
  /// Default constructor
  Api(this.baseUrl,
      [String tokenKey = 'token',
      Duration timeout = const Duration(seconds: 5)]) {
    final Persistence persist = PersistenceClient();
    account = AccountApi(
        HttpClient(
            baseUrl: '$baseUrl/v2/Account',
            persist: persist,
            tokenKey: tokenKey,
            timeout: timeout),
        persist);
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
    week = WeekApi(HttpClient(
        baseUrl: '$baseUrl/v1/Week',
        persist: persist,
        tokenKey: tokenKey,
        timeout: timeout));
    pictogram = PictogramApi(HttpClient(
        baseUrl: '$baseUrl/v1/Pictogram',
        persist: persist,
        tokenKey: tokenKey,
        timeout: timeout));
    activity = ActivityApi(HttpClient(
        baseUrl: '$baseUrl/v2/Activity',
        persist: persist,
        tokenKey: tokenKey,
        timeout: timeout));
    weekTemplate = WeekTemplateApi(HttpClient(
        baseUrl: '$baseUrl/v1/WeekTemplate',
        persist: persist,
        tokenKey: tokenKey,
        timeout: timeout));
    user = UserApi(HttpClient(
        baseUrl: '$baseUrl/v1/User',
        persist: persist,
        tokenKey: tokenKey,
        timeout: timeout));
    alternateName = AlternateNameApi(HttpClient(
      baseUrl: '$baseUrl/v2/AlternateName',
      persist: persist,
      tokenKey: tokenKey,
      timeout: timeout));
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

  /// To access alternateName endpoints
  AlternateNameApi alternateName;

  /// The base of all requests.
  ///
  /// Example: if set to `http://google.com`, then a get request with url
  /// `/search` will resolve to `http://google.com/search`
  String baseUrl;

  /// Destroy the API
  void dispose() {}
}
