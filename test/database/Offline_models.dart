import 'package:api_client/models/activity_model.dart';
import 'package:api_client/models/enums/access_level_enum.dart';
import 'package:api_client/models/enums/activity_state_enum.dart';
import 'package:api_client/models/enums/role_enum.dart';
import 'package:api_client/models/enums/weekday_enum.dart';
import 'package:api_client/models/giraf_user_model.dart';
import 'package:api_client/models/pictogram_model.dart';
import 'package:api_client/models/timer_model.dart';
import 'package:api_client/models/week_model.dart';
import 'package:api_client/models/week_template_model.dart';
import 'package:api_client/models/weekday_model.dart';

//Test GirafUserModel 1
final GirafUserModel jamesbondTestUser = GirafUserModel(
    username: 'JamesBond007',
    department: 1,
    displayName: 'James Bond',
    roleName: 'Citizen',
    id: 'james007bond',
    role: Role.Citizen,
    offlineId: 1);
// Test account body 1
final Map<String, dynamic> jamesBody = <String, dynamic>{
  'username': jamesbondTestUser.username,
  'displayName': jamesbondTestUser.displayName,
  'password': 'TestPassword123',
  'department': jamesbondTestUser.department,
  'role': jamesbondTestUser.role.toString().split('.').last
};
//Test GirafUserModel 2
final GirafUserModel edTestUser = GirafUserModel(
    department: 34,
    offlineId: 34,
    role: Role.Citizen,
    id: 'edmcniel01',
    roleName: 'Citizen',
    displayName: 'Ed McNiel',
    username: 'EdMcNiel34');
//Test account body 2
final Map<String, dynamic> edBody = <String, dynamic>{
  'username': edTestUser.username,
  'displayName': edTestUser.displayName,
  'password': 'MyPassword42',
  'department': edTestUser.department,
  'role': edTestUser.role.toString().split('.').last
};
//Test Pictogram 1
final PictogramModel scrum = PictogramModel(
    accessLevel: AccessLevel.PUBLIC,
    id: 44,
    title: 'Picture of Scrum',
    lastEdit: DateTime.now(),
    userId: '1');

//Test Pictogram 2
final PictogramModel extreme = PictogramModel(
    accessLevel: AccessLevel.PROTECTED,
    id: 20,
    title: 'Picture of XP',
    lastEdit: DateTime.now(),
    userId: '3');

//Lists of test pictograms
List<PictogramModel> testListe = <PictogramModel>[scrum];
List<PictogramModel> testListe2 = <PictogramModel>[extreme];

//Test ActivityModel 1
final ActivityModel lege = ActivityModel(
  id: 69,
  isChoiceBoard: true,
  order: 1,
  pictograms: testListe,
  choiceBoardName: 'Testchoice',
  state: ActivityState.Active,
  timer: null,
);

//Test ActivityModel 2
final ActivityModel spise = ActivityModel(
  id: 70,
  pictograms: testListe2,
  order: 2,
  state: ActivityState.Active,
  isChoiceBoard: true,
  choiceBoardName: 'Testsecondchoice',
  timer: null,
);

//Test Timer
final TimerModel timer = TimerModel(
  startTime: DateTime.now(),
  progress: 1,
  fullLength: 10,
  paused: false,
  key: 44,
);

final List<ActivityModel> legeday = <ActivityModel>[lege];
final List<ActivityModel> spiseday = <ActivityModel>[spise];

final WeekdayModel redditday =
    WeekdayModel(day: Weekday.Tuesday, activities: legeday);

final WeekdayModel redditday2 =
    WeekdayModel(day: Weekday.Friday, activities: legeday);

final List<WeekdayModel> redditweek = <WeekdayModel>[redditday];
final WeekModel redditWeek = WeekModel(
    days: redditweek,
    name: 'RedditWeek',
    thumbnail: scrum,
    weekNumber: 44,
    weekYear: 2020);

final WeekTemplateModel weekTemplate1 = WeekTemplateModel(
    days: redditweek,
    name: 'TestReddit',
    departmentKey: 3,
    id: 44,
    thumbnail: extreme);
final WeekTemplateModel weekTemplate2 = WeekTemplateModel(
    days: redditweek,
    name: 'TestReddit2',
    departmentKey: 2,
    id: 40,
    thumbnail: scrum);
