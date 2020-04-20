import 'package:api_client/http/http.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:api_client/models/giraf_user_model.dart';
import 'package:api_client/models/enums/role_enum.dart';
import 'package:api_client/persistence/persistence.dart';

/// All Account Endpoints
class AccountApi {
  /// Default constructor
  AccountApi(this._http, this._persist);

  final Http _http;
  final Persistence _persist;

  /// This endpoint allows the user to sign in to his/her account by providing
  /// valid username and password
  ///
  /// [username] The users username
  /// [password] The users password
  Observable<bool> login(String username, String password) {
    return _http.post('/Account/login', <String, String>{
      'username': username,
      'password': password,
    }).flatMap((Response res) =>
        Observable<bool>.fromFuture(_persist.set('token', res.json['data'])));
  }

  /// Register a new user
  ///
  /// [username] The users username
  /// [password] The users password
  /// [displayName] The users DisplayName
  /// [departmentId] The users departmentId
  /// [role] The role of the user
  Observable<GirafUserModel> register(String username, String password,
      {@required String displayName, @required int departmentId,
        @required Role role}) {
    final Map<String, dynamic> body = <String, dynamic>{
      'username': username,
      'displayName': displayName,
      'password': password,
      'departmentId': departmentId,
      'role': role.toString().split('.').last,
    };

    return _http
        .post('/Account/register', body)
        .map((Response res) => GirafUserModel.fromJson(res.json['data']));
  }

  /// Allows the user to change his password if they know their old password.
  ///
  /// []
  /// [oldPassword] The users current password.
  /// [newPassword] The desired password.
  Observable<bool> changePasswordWithOld(
      String id, String oldPassword, String newPassword) {
    return _http.put('/User/$id/Account/password', <String, String>{
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    }).map((Response res) {
      return res.json['success'];
    });
  }

  /// Allows a user to set a new password if they forgot theirs.
  ///
  /// [password] The users password.
  /// [token] Reset password token. Used when a user request a password reset.
  Observable<bool> changePassword(String id, String password, String token) {
    return _http.post('/User/$id/Account/password', <String, String>{
      password: password,
      token: token,
    }).map((Response res) {
      return res.json['success'];
    });
  }

  /// Allows the user to get a password reset token for a given user
  ///
  /// [id] ID of the user
  Observable<String> resetPasswordToken(String id) {
    return _http
        .get('/User/$id/Account/password-reset-token')
        .map((Response res) => res.json['data']);
  }

  /// Deletes the user with the given ID
  ///
  /// [id] ID of the user
  Observable<bool> delete(String id) {
    return _http.delete('/Account/user/$id').flatMap((Response res) =>
        Observable<bool>.fromFuture(_persist.remove('token')));
  }

  /// Logout the currently logged in user
  Observable<void> logout() {
    return Observable<void>.fromFuture(Future<void>(() async {
      await _persist.remove('token');
    }));
  }
}
