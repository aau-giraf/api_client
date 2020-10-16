import 'package:api_client/http/http.dart';
import 'package:api_client/offline_database/offline_db_handler.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:api_client/models/giraf_user_model.dart';
import 'package:api_client/models/enums/role_enum.dart';
import 'package:api_client/persistence/persistence.dart';

/// All Account Endpoints
class AccountApi {
  /// Default constructor
  AccountApi(this._http, this._persist, this.dbHandler);

  final Http _http;
  final Persistence _persist;
  final OfflineDbHandler dbHandler;

  /// This endpoint allows the user to sign in to his/her account by providing
  /// valid username and password
  ///
  /// [username] The users username
  /// [password] The users password
  Stream<bool> login(String username, String password) {
    return _http.post('/Account/login', <String, String>{
      'username': username,
      'password': password,
    }).flatMap((Response res) =>
        Stream<bool>.fromFuture(_persist.set('token', res.json['data'])));
  }

  /// Register a new user
  ///
  /// [username] The users username
  /// [password] The users password
  /// [displayName] The users DisplayName
  /// [departmentId] The users departmentId
  /// [role] The role of the user
  Stream<GirafUserModel> register(
      String username, String password, String displayName,
      {@required int departmentId, @required Role role}) {
    final Map<String, dynamic> body = <String, dynamic>{
      'username': username,
      'displayName': displayName,
      'password': password,
      'departmentId': departmentId,
      'role': role.toString().split('.').last,
    };

    ///return body to local db
    dbHandler.registerAccount(body);
    return _http
        .post('/Account/register', body)
        .map((Response res) => GirafUserModel.fromJson(res.json['data']));
  }

  /// Allows the user to change his password if they know their old password.
  ///
  /// []
  /// [oldPassword] The users current password.
  /// [newPassword] The desired password.
  Stream<bool> changePasswordWithOld(
      String id, String oldPassword, String newPassword) {
    return _http.put('/User/$id/Account/password', <String, String>{
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    }).map((Response res) {
      return res.success();
    });
  }

  /// Allows a user to set a new password if they forgot theirs.
  ///
  /// [password] The users password.
  /// [token] Reset password token. Used when a user request a password reset.
  Stream<bool> changePassword(String id, String password, String token) {
    return _http.post('/User/$id/Account/password', <String, String>{
      password: password,
      token: token,
    }).map((Response res) {
      return res.success();
    });
  }

  /// Allows the user to get a password reset token for a given user
  ///
  /// [id] ID of the user
  Stream<String> resetPasswordToken(String id) {
    return _http
        .get('/User/$id/Account/password-reset-token')
        .map((Response res) => res.json['data']);
  }

  /// Deletes the user with the given ID
  ///
  /// [id] ID of the user
  Stream<bool> delete(String id) {
    ///delete from local db
    dbHandler.deleteAccount(id);
    return _http.delete('/Account/user/$id').flatMap(
        (Response res) => Stream<bool>.fromFuture(_persist.remove('token')));
  }

  /// Logout the currently logged in user
  Stream<void> logout() {
    return Stream<void>.fromFuture(Future<void>(() async {
      await _persist.remove('token');
    }));
  }
}
