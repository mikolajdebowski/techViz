import 'package:flutter/material.dart';
import 'package:techviz/components/charts/stackedHorizontalBarChart.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizStepper.dart';

import 'package:techviz/presenter/roleListPresenter.dart';
import 'package:techviz/repository/session.dart';
import 'package:techviz/model/role.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/presenter/statusListPresenter.dart';

/// Bar chart example
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

import 'dart:async';
import 'dart:convert';

class Profile extends StatefulWidget {
  Profile() {}

  @override
  State<StatefulWidget> createState() {
    return ProfileState();
  }
}

class ProfileState extends State<Profile>
    implements IRoleListPresenter<Role>, IStatusListPresenter<UserStatus> {
  List<ProfileItem> _userInfo = [];
  RoleListPresenter roleListPresenter;
  StatusListPresenter statusListPresenter;

  int current_step = 0;

  static List<charts.Series<TodayStats, String>> _createData( String columnName, dynamic val1, dynamic val2) {

    print('columnName ${columnName}, value ${val1}, value ${val2}');

    final todayStatsA = [
      TodayStats('Personal', num.parse(val1.toString())),
    ];

    final todayStatsB = [
      TodayStats('Team Avg', num.parse(val2.toString())),
    ];

    return [
      new charts.Series<TodayStats, String>(
        id: 'Team Avg',
        domainFn: (TodayStats stats, _) => stats.name,
        measureFn: (TodayStats stats, _) => stats.value,
        data: todayStatsB,
        labelAccessorFn: (TodayStats sales, _) => '${sales.value.toString()}'),
      new charts.Series<TodayStats, String>(
        id: 'Personal',
        domainFn: (TodayStats sales, _) => sales.name,
        measureFn: (TodayStats sales, _) => sales.value,
        data: todayStatsA,
        labelAccessorFn: (TodayStats sales, _) => '${sales.value.toString()}'),
    ];
  }

  List<VizStep> my_steps = [];

  @override
  void initState(){
    Session session = Session();
    roleListPresenter = RoleListPresenter(this);
    roleListPresenter.loadUserRoles(session.user.UserID);

    statusListPresenter = StatusListPresenter(this);
    statusListPresenter.loadUserRoles(session.user.UserID);

    Map<String, String> usrMap = {
      'UserID': session.user.UserID,
      'UserName': session.user.UserName,
      'UserRoleID': session.user.UserRoleID.toString(),
      'UserStatusID': session.user.UserStatusID.toString(),
    };

    setState(() {
      usrMap.forEach((k, v) {
        var item = ProfileItem(columnName: '${k}', value: '${v}');
        _userInfo.add(item);
      });
    });

    loadStats();


    super.initState();
  }


  void loadStats() async{

    var statsList = await Future.wait([loadUserStats(), loadTeamStats()]);
    var userStatsRaw = statsList[0];
    var teamStatsRaw = statsList[1];

    Map<String,dynamic> decodedUser = json.decode(userStatsRaw);
    List<dynamic> rowsUser = decodedUser['Rows'];
    var _columnNamesUser = (decodedUser['ColumnNames'] as String).split(',');
    Map<String, dynamic> userStatsMap;

    rowsUser.forEach((dynamic d) {
      dynamic values = d['Values'];

      userStatsMap = Map<String, dynamic>();
      userStatsMap['TimeAvailable'] = values[_columnNamesUser.indexOf("TimeAvailable")];
      userStatsMap['TasksPerHour'] = values[_columnNamesUser.indexOf("TasksPerHour")];
      userStatsMap['AvgResponseTime'] = values[_columnNamesUser.indexOf("AvgResponseTime")];
      userStatsMap['AvgCompletionTime'] = values[_columnNamesUser.indexOf("AvgCompletionTime")];
      userStatsMap['TasksEscalated'] = values[_columnNamesUser.indexOf("TasksEscalated")];
      userStatsMap['PercentEscalated'] = values[_columnNamesUser.indexOf("PercentEscalated")];

//    Duration timeAvailable = new Duration(seconds: int.parse(userStatsMap['TimeAvailable'].toString()) );
//    print(timeAvailable.toString());
    });


    Map<String,dynamic> decodedTeam = json.decode(teamStatsRaw);
    List<dynamic> rowsTeam = decodedTeam['Rows'];
    var _columnNamesTeam = (decodedTeam['ColumnNames'] as String).split(',');
    Map<String, dynamic> teamStatsMap;

    rowsTeam.forEach((dynamic d) {
      dynamic values = d['Values'];

      teamStatsMap = Map<String, dynamic>();
      teamStatsMap['TimeAvailable'] = values[_columnNamesTeam.indexOf("AvgTimeAvailable")];
      teamStatsMap['TasksPerHour'] = values[_columnNamesTeam.indexOf("AvgTasksPerHour")];
      teamStatsMap['AvgResponseTime'] = values[_columnNamesTeam.indexOf("AvgResponseTime")];
      teamStatsMap['AvgCompletionTime'] = values[_columnNamesTeam.indexOf("AvgCompletionTime")];
      teamStatsMap['TasksEscalated'] = values[_columnNamesTeam.indexOf("AvgTasksEscalated")];
      teamStatsMap['PercentEscalated'] = values[_columnNamesTeam.indexOf("AvgPercentEscalated")];

//    Duration timeAvailable = new Duration(seconds: int.parse(teamStatsMap['TimeAvailable'].toString()) );
//    print(timeAvailable.toString());
    });


    setState(() {
      userStatsMap.forEach((columnName, dynamic v) {

        var step = VizStep(
            title: insertSpaces(columnName),
            content: Container(
              width: 100,
              height: 100,
              child: StackedHorizontalBarChart(_createData(columnName, v, teamStatsMap[columnName])),
            ),
            isActive: true);

        my_steps.add(step);

      });

      for (int i = 0; i < my_steps.length; i += 1)
        my_steps[i].isActive = false;

      my_steps[0].isActive = true;
    });

  }

  String insertSpaces(String columnName) {
    columnName = columnName.split(RegExp("(?=[A-Z])")).join(" ");
    return columnName;
  }

  Future<String> loadUserStats() async {
    return await rootBundle.loadString('assets/json/UserStatsCurrentDay.json');
  }

  Future<String> loadTeamStats() async {
    return await rootBundle.loadString('assets/json/TeamStatsCurrentDay.json');
  }

  Future<String> loadTeamTasks() async {
    return await rootBundle.loadString('assets/json/TeamTasksCompletedCurrentDay.json');
  }

  Widget _buildProfileItem(BuildContext context, int index) {
    return Container(
      height: 70.0,
      margin: EdgeInsets.only(top: 0.0, bottom: 0.0, left: 0.0, right: 0.0),
      color: (index % 2 == 0 ? Color(0xFFeff4f5) : Color(0xFFffffff)),
      child: ListTile(
        title: Text(_userInfo[index].columnName),
        subtitle: Text(_userInfo[index].value),
      ),
    );
  }

  Widget _buildProfileList() {
    Widget list;
    if (_userInfo.length > 0) {
      list = ListView.builder(
        itemCount: _userInfo.length,
        itemBuilder: _buildProfileItem,
      );
    } else {
      list = Center(
        child: Text('No profile info to render'),
      );
    }

    return list;
  }

  Widget _buildRightChild() {
    if (my_steps.length > 0) {
      return VizStepper(
        controlsBuilder: (BuildContext context, {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
          return Row(
            children: <Widget>[
              Container(),
              Container(),
            ],
          );
        },

        currentStep: this.current_step,
        steps: my_steps,
        type: VizStepperType.horizontal,

        onStepTapped: (step) {
          print("view loaded : " + step.toString());

          setState(() {

            for (int i = 0; i < my_steps.length; i += 1)
              my_steps[i].isActive = false;

            my_steps[step].isActive = true;
            current_step = step;
          });
        },

      );
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    var leftPanel = Expanded(flex: 1, child: _buildProfileList());
    var rightPanel = Expanded(
      flex: 2,
      child: Container(
          child: _buildRightChild()),
    );

    Container container = Container(
      child: Padding(
          padding: EdgeInsets.all(0.0),
          child: Row(
            children: <Widget>[leftPanel, rightPanel],
          )),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFF586676), Color(0xFF8B9EA7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              tileMode: TileMode.repeated)),
    );

    var safe = SafeArea(child: container, top: false, bottom: false);

    return Scaffold(backgroundColor: Colors.black, appBar: ActionBar(title: 'My Profile'), body: safe);
  }

  @override
  void onLoadError(Error error) {
    // TODO: implement onLoadError
  }

  @override
  void onRoleListLoaded(List<Role> result) {
    if (result.length == 1) {
      return;
    }

//Session session = Session();
//var user = session.user;

    print("roles loaded");

//    setState(() {
//      roleList = result;
//    });
  }

  @override
  void onStatusListLoaded(List<UserStatus> result) {
// TODO: implement onStatusListLoaded
//
//    Session session = Session();
//    var user = session.user;

    print("statuses loaded");
//    setState(() {
//      roleList = result;
//    });
  }
}

abstract class ListItem {}

// A ListItem that contains data to display a message
class ProfileItem implements ListItem {
  final String columnName;
  final String value;

  ProfileItem({this.columnName, this.value});
}
