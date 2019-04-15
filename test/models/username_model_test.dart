import 'package:api_client/models/enums/role_enum.dart';
import 'package:api_client/models/giraf_user_model.dart';
import 'package:test_api/test_api.dart';
import 'package:api_client/models/username_model.dart';

void main() {
  test('Throws on JSON is null', () {
    const Map<String, dynamic> json = null; // ignore: avoid_init_to_null
    expect(() => UsernameModel.fromJson(json), throwsFormatException);
  });

  test('Can create from JSON map', () {
    final Map<String, dynamic> json = <String, dynamic>{
      'userName': 'testUsername',
      'userRole': 'testRole',
      'userId': 'testID',
    };

    final UsernameModel model = UsernameModel.fromJson(json);
    expect(model.id, json['userId']);
    expect(model.role, json['userRole']);
    expect(model.name, json['userName']);
  });

  test('Can convert to JSON map', () {
    final Map<String, dynamic> json = <String, dynamic>{
      'userName': 'testUsername',
      'userRole': 'testRole',
      'userId': 'testID',
    };

    final UsernameModel model = UsernameModel.fromJson(json);

    expect(model.toJson(), json);
  });

  test('Can create from GirafUserModel', () {
    final GirafUserModel girafUser = GirafUserModel(
      roleName: Role.Guardian.toString(),
      screenName: 'User',
      id: '1',
    );

    final UsernameModel user = UsernameModel.fromGirafUser(girafUser);

    expect(user.role, girafUser.roleName);
    expect(user.name, girafUser.screenName);
    expect(user.id, girafUser.id);
  });

  test('Has username property', () {
    const String username = 'testUsername';
    final UsernameModel model =
        UsernameModel(name: username, role: null, id: null);
    expect(model.name, username);
  });

  test('Has role property', () {
    const String role = 'testRole';
    final UsernameModel model = UsernameModel(name: null, role: role, id: null);
    expect(model.role, role);
  });

  test('Has id property', () {
    const String id = 'testId';
    final UsernameModel model = UsernameModel(name: null, role: null, id: id);
    expect(model.id, id);
  });
}
