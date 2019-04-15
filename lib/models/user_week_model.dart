import 'package:api_client/models/username_model.dart';
import 'package:api_client/models/week_model.dart';

/// Collection of user and its week.
class UserWeekModel {
  /// The state of the WeekPlan BLoC, with both [week] and [user] (citizen).
  UserWeekModel(this.week, this.user);

  /// The week that a weekplan describes
  final WeekModel week;

  /// The citizen
  final UsernameModel user;
}
