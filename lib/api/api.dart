
import 'package:api_client/api/account_api.dart';
import 'package:api_client/api/department_api.dart';
import 'package:api_client/http/http_client.dart';
import 'package:api_client/api/pictogram_api.dart';
import 'package:api_client/api/status_api.dart';
import 'package:api_client/api/user_api.dart';
import 'package:api_client/api/week_api.dart';
import 'package:api_client/api/week_template_api.dart';
import 'package:api_client/persistence/persistence.dart';
import 'package:api_client/persistence/persistence_client.dart';

/// Weekplanner API
class Api {
  /// Default constructor
  Api(this.baseUrl) {
    final Persistence persist = PersistenceClient();
    account = AccountApi(HttpClient(baseUrl + '/v1', persist), persist);
    status = StatusApi(HttpClient(baseUrl + '/v1/Status', persist));
    department = DepartmentApi(HttpClient(baseUrl + '/v1/Department', persist));
    week = WeekApi(HttpClient(baseUrl + '/v1/User', persist));
    pictogram = PictogramApi(HttpClient(baseUrl + '/v1/Pictogram', persist));
    weekTemplate =
        WeekTemplateApi(HttpClient(baseUrl + '/v1/WeekTemplate', persist));
    user = UserApi(HttpClient(baseUrl + '/v1/User', persist));
  }

  /// To access account endpoints
  AccountApi account;

  /// To access department endpoints
  DepartmentApi department;

  /// To access pictogram endpoints
  PictogramApi pictogram;

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
