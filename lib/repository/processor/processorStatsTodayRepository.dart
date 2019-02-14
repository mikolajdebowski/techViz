import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:flutter/services.dart';
import 'package:techviz/components/charts/vizChart.dart';
import 'package:techviz/repository/remoteRepository.dart';


class ProcessoStatsTodayRepository extends IRemoteRepository<dynamic>{

  var columnsToBeIgnored = ["SiteID", "UserID"];

  @override
  Future fetch() async {
    print('Fetching '+this.toString());

    ChartData extractDataFromValues(List<String> columnNames, String columnName, dynamic values){
      return ChartData(columnName, num.parse(values[columnNames.indexOf(columnName)] as String));
    }

    Completer<Map<int,List<ChartData>>> _completer = Completer<Map<int,List<ChartData>>>();

    var futureUser = rootBundle.loadString('assets/json/UserStatsCurrentDay.json');
    var futureTeam = rootBundle.loadString('assets/json/TeamStatsCurrentDay.json');

    Future.wait([futureUser, futureTeam]).then((List<String> json){
      var jsonUser = json[0];
      var jsonTeam = json[1];

      Map<String,dynamic> decodedUser = jsonDecode(jsonUser);
      Map<String,dynamic> decodedTeam = jsonDecode(jsonTeam);

      List<dynamic> rowsUser = decodedUser['Rows'];
      List<String> columnNamesUser = (decodedUser['ColumnNames'] as String).split(',');

      List<dynamic> rowsTeam = decodedTeam['Rows'];
      List<String> columnNamesTeam = (decodedTeam['ColumnNames'] as String).split(',');


      List<ChartData> chartTimeAvailable = [];
      chartTimeAvailable.add(extractDataFromValues(columnNamesUser, 'TimeAvailable', rowsUser[0]['Values']));
      chartTimeAvailable.add(extractDataFromValues(columnNamesTeam, 'AvgTimeAvailable', rowsTeam[0]['Values']));

      Map<int,List<ChartData>> mapToReturn = Map<int,List<ChartData>>();
      mapToReturn[0] = chartTimeAvailable;

      _completer.complete(mapToReturn);
    });

    return _completer.future;



//
//    var statsList = await Future.wait([loadUserStats(), loadTeamStats(), loadTeamTasks()]);
//    var userStatsRaw = statsList[0];
//    var teamStatsRaw = statsList[1];
//    var teamTeamTasksRaw = statsList[2];
//
//    Map<String,dynamic> decodedUser = json.decode(userStatsRaw);
//    List<dynamic> rowsUser = decodedUser['Rows'];
//    var _columnNamesUser = (decodedUser['ColumnNames'] as String).split(',');
//    Map<String, dynamic> userStatsMap;
//
//    rowsUser.forEach((dynamic d) {
//      dynamic values = d['Values'];
//
//      userStatsMap = Map<String, dynamic>();
//      userStatsMap['TimeAvailable'] = values[_columnNamesUser.indexOf("TimeAvailable")];
//      userStatsMap['TasksPerHour'] = values[_columnNamesUser.indexOf("TasksPerHour")];
//      userStatsMap['AvgResponseTime'] = values[_columnNamesUser.indexOf("AvgResponseTime")];
//      userStatsMap['AvgCompletionTime'] = values[_columnNamesUser.indexOf("AvgCompletionTime")];
//      userStatsMap['TasksEscalated'] = values[_columnNamesUser.indexOf("TasksEscalated")];
//      userStatsMap['PercentEscalated'] = values[_columnNamesUser.indexOf("PercentEscalated")];
//    });
//
//
//    Map<String,dynamic> decodedTeam = json.decode(teamStatsRaw);
//    List<dynamic> rowsTeam = decodedTeam['Rows'];
//    var _columnNamesTeam = (decodedTeam['ColumnNames'] as String).split(',');
//    Map<String, dynamic> teamStatsMap;
//
//    rowsTeam.forEach((dynamic d) {
//      dynamic values = d['Values'];
//
//      teamStatsMap = Map<String, dynamic>();
//      teamStatsMap['TimeAvailable'] = values[_columnNamesTeam.indexOf("AvgTimeAvailable")];
//      teamStatsMap['TasksPerHour'] = values[_columnNamesTeam.indexOf("AvgTasksPerHour")];
//      teamStatsMap['AvgResponseTime'] = values[_columnNamesTeam.indexOf("AvgResponseTime")];
//      teamStatsMap['AvgCompletionTime'] = values[_columnNamesTeam.indexOf("AvgCompletionTime")];
//      teamStatsMap['TasksEscalated'] = values[_columnNamesTeam.indexOf("AvgTasksEscalated")];
//      teamStatsMap['PercentEscalated'] = values[_columnNamesTeam.indexOf("AvgPercentEscalated")];
//    });
//
//    Map<String,dynamic> decodedTeamTasks = json.decode(teamTeamTasksRaw);
//    List<dynamic> rowsTeamTasks = decodedTeamTasks['Rows'];
//    var _columnNamesTeamTasks = (decodedTeamTasks['ColumnNames'] as String).split(',');
//    List<dynamic> teamTasksMapAll = new List<dynamic>();
//
//    rowsTeamTasks.forEach((dynamic d) {
//      dynamic values = d['Values'];
//
//      Map<String, dynamic> teamTasksMap = Map<String, dynamic>();
//      teamTasksMap['SiteID'] = values[_columnNamesTeamTasks.indexOf("SiteID")];
//      teamTasksMap['TaskTypeID'] = values[_columnNamesTeamTasks.indexOf("TaskTypeID")];
//      teamTasksMap['TaskDescription'] = values[_columnNamesTeamTasks.indexOf("TaskDescription")];
//      teamTasksMap['AvgTasksCompleted'] = values[_columnNamesTeamTasks.indexOf("AvgTasksCompleted")];
//
//      teamTasksMapAll.add(teamTasksMap);
//    });
//
//    userStatsMap['TasksCompletedByType'] = teamTasksMapAll;


  }


}