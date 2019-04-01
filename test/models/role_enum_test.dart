import 'package:test_api/test_api.dart';
import 'package:api_client/models/enums/role_enum.dart';

void main() {
  test('Should contain a specific list of values', () {
    expect(Role.Citizen.index, 0);
    expect(Role.Department.index, 1);
    expect(Role.Guardian.index, 2);
    expect(Role.SuperUser.index, 3);
  });
}
