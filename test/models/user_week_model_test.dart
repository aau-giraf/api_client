import 'package:api_client/models/enums/role_enum.dart';
import 'package:api_client/models/user_week_model.dart';
import 'package:api_client/models/username_model.dart';
import 'package:api_client/models/week_model.dart';
import 'package:test_api/test_api.dart';

void main() {
  test('Can add week and user', () {
    final WeekModel week = WeekModel();
    final UsernameModel user =
        UsernameModel(name: 'User', role: Role.Guardian.toString(), id: '1');

    final UserWeekModel userWeek = UserWeekModel(week, user);

    expect(week, userWeek.week);
    expect(user, userWeek.user);
  });
}
