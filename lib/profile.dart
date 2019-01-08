import 'package:flutter/material.dart';
import 'package:techviz/components/charts/groupedBarChart.dart';
import 'package:techviz/components/charts/pieChart.dart';
import 'package:techviz/components/charts/stackedHorizontalBarChart.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:techviz/components/vizLegend.dart';
import 'package:techviz/components/vizStepper.dart';
import 'package:techviz/model/user.dart';

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

  List<Role> rolesList = List<Role>();
  List<UserStatus> userStatusList = List<UserStatus>();

  String _currentRole;
  String _currentStatus;

  void changedStatusDropDownItem(String selectedStatus) {
    setState(() {
      _currentStatus = selectedStatus;
    });
  }

  void changedRoleDropDownItem(String selectedRole) {
    setState(() {
      _currentRole = selectedRole;
    });
  }


  // Create one series with sample hard coded data.
  static List<charts.Series<LinearSales, num>> _createPieChartData(dynamic value) {

    final todayStats = [
      LinearSales(100 - num.parse(value.toString())),
      LinearSales(num.parse(value.toString())),
    ];


    return [
      new charts.Series<LinearSales, num>(
          id: 'todayStats',
          domainFn: (LinearSales sales, _) => sales.percent,
          measureFn: (LinearSales sales, _) => sales.percent,
          data: todayStats,
          labelAccessorFn: (LinearSales row, _) => '${row.percent.round()}%'
      )
    ];
  }

  /// Create series list with multiple series
  static List<charts.Series<AvgTasksCompleted, String>> _createDataForTasks(List<dynamic> tasksCompletedByType) {

    final averageData = <AvgTasksCompleted>[];

    tasksCompletedByType.forEach((dynamic element) {
//      print(element);
      String desc = element['TaskDescription'].toString();
      double avrTasksCompleted = double.parse(element['AvgTasksCompleted'].toString());
      AvgTasksCompleted task = AvgTasksCompleted(desc, avrTasksCompleted);
      averageData.add(task);
    });



    final personalData = [
      new AvgTasksCompleted('Change Light', 2.0),
      new AvgTasksCompleted('Jackpot', 1.0),
      new AvgTasksCompleted('Printer', 3.0),
    ];

    return [
      new charts.Series<AvgTasksCompleted, String>(
        id: 'PersonalData',
        domainFn: (AvgTasksCompleted sales, _) => sales.name,
        measureFn: (AvgTasksCompleted sales, _) => sales.avrTasksCompleted,
        data: personalData,
      ),
      new charts.Series<AvgTasksCompleted, String>(
        id: 'AvrData',
        domainFn: (AvgTasksCompleted sales, _) => sales.name,
        measureFn: (AvgTasksCompleted sales, _) => sales.avrTasksCompleted,
        data: averageData,
      ),
    ];
  }


  static List<charts.Series<TodayStats, String>> _createData( String columnName, dynamic val1, dynamic val2) {

//    print('columnName ${columnName}, value ${val1}, value ${val2}');

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
          labelAccessorFn: (TodayStats sales, _){
            if(columnName == 'TimeAvailable'){
              Duration timeAvailable = new Duration(seconds: int.parse(sales.value.toString()) );
              return '${timeAvailable.inHours} hr ${timeAvailable.inMinutes%60} min';
            }else{
              return '${sales.value.toString()}';
            }
          }

      ),
      new charts.Series<TodayStats, String>(
          id: 'Personal',
          domainFn: (TodayStats sales, _) => sales.name,
          measureFn: (TodayStats sales, _) => sales.value,
          data: todayStatsA,
          labelAccessorFn: (TodayStats sales, _){
            if(columnName == 'TimeAvailable'){
              Duration timeAvailable = new Duration(seconds: int.parse(sales.value.toString()) );
              return '${timeAvailable.inHours} hr ${timeAvailable.inMinutes%60} min';
            }else{
              return '${sales.value.toString()}';
            }
          }
      ),
    ];
  }

  List<VizStep> my_steps = [];

  @override
  void initState(){

    rolesList.add(Role());
    userStatusList.add(UserStatus());

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

    var statsList = await Future.wait([loadUserStats(), loadTeamStats(), loadTeamTasks()]);
    var userStatsRaw = statsList[0];
    var teamStatsRaw = statsList[1];
    var teamTeamTasksRaw = statsList[2];

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
    });

    Map<String,dynamic> decodedTeamTasks = json.decode(teamTeamTasksRaw);
    List<dynamic> rowsTeamTasks = decodedTeamTasks['Rows'];
    var _columnNamesTeamTasks = (decodedTeamTasks['ColumnNames'] as String).split(',');
    List<dynamic> teamTasksMapAll = new List<dynamic>();

    rowsTeamTasks.forEach((dynamic d) {
      dynamic values = d['Values'];

      Map<String, dynamic> teamTasksMap = Map<String, dynamic>();
      teamTasksMap['SiteID'] = values[_columnNamesTeamTasks.indexOf("SiteID")];
      teamTasksMap['TaskTypeID'] = values[_columnNamesTeamTasks.indexOf("TaskTypeID")];
      teamTasksMap['TaskDescription'] = values[_columnNamesTeamTasks.indexOf("TaskDescription")];
      teamTasksMap['AvgTasksCompleted'] = values[_columnNamesTeamTasks.indexOf("AvgTasksCompleted")];

      teamTasksMapAll.add(teamTasksMap);
    });

    userStatsMap['TasksCompletedByType'] = teamTasksMapAll;

    setState(() {
      userStatsMap.forEach((columnName, dynamic v) {

        Widget chart;
        double radius = 133.0;

        if(columnName.contains('Percent')){
          chart = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(children: <Widget>[
                Container(
                  width: radius,
                  height: radius,
                  child: SimplePieChart(_createPieChartData(v)),
                ),
                Text('Personal')
              ],),
              Column(children: <Widget>[
                Container(
                  width: radius,
                  height: radius,
                  child: SimplePieChart(_createPieChartData(teamStatsMap[columnName])),
                ),
                Text('Team Avg')
              ],),
            ],);

        }else if(columnName.contains('TasksCompletedByType')){
          chart =  Row(children: <Widget>[
            Container(
              width: 257,
              height: 140,
              child: GroupedBarChart(_createDataForTasks(userStatsMap['TasksCompletedByType'] as List<dynamic>)),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
              child: VizLegend(),
            ),
          ],);
        }else{
          chart = StackedHorizontalBarChart(_createData(columnName, v, teamStatsMap[columnName]));
        }

        var step = VizStep(
            title: insertSpaces(columnName),
            content: Container(
              width: 150,
              height: 150,
              child: chart,
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

    Widget subItem;
    if(_userInfo[index].columnName == 'UserStatusID'){
      subItem = DropdownButton(
        value: _currentStatus,
        items: userStatusList.map((UserStatus status){
          return DropdownMenuItem(
            value: '${status.description}',
            child: Text('${status.description}'),
          );
        }).toList(),
        onChanged: changedStatusDropDownItem,
      );

    }else if(_userInfo[index].columnName == 'UserRoleID'){
      subItem = DropdownButton(
        value: _currentRole,
        items: rolesList.map((Role val){
          return DropdownMenuItem(
            value: '${val.description}',
            child: Text('${val.description}'),
          );
        }).toList(),
        onChanged: changedRoleDropDownItem,
      );
    }
    else{
      subItem = Text(_userInfo[index].value);
    }

    return Container(
      height: 70.0,
      margin: EdgeInsets.only(top: 0.0, bottom: 0.0, left: 0.0, right: 0.0),
      color: (index % 2 == 0 ? Color(0xFFeff4f5) : Color(0xFFffffff)),
      child: ListTile(
        title: Text(_userInfo[index].columnName),
        subtitle: subItem,
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

    setState(() {
      rolesList = result;

      Session session = Session();
      User user = session.user;
      rolesList.forEach((Role role) {
        if(role.id.toString() == user.UserStatusID.toString()){
          _currentRole = role.description;
        }
      });
    });
  }

  @override
  void onStatusListLoaded(List<UserStatus> result) {
    if (result.length == 1) {
      return;
    }

    setState(() {
      userStatusList = result;

      Session session = Session();
      User user = session.user;
      userStatusList.forEach((UserStatus status) {
        if(status.id.toString() == user.UserStatusID.toString()){
          _currentStatus = status.description;
        }
      });

    });

//    print('done');
  }
}

abstract class ListItem {}

// A ListItem that contains data to display a message
class ProfileItem implements ListItem {
  final String columnName;
  final String value;

  ProfileItem({this.columnName, this.value});
}