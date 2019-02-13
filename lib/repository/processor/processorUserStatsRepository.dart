import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:techviz/components/charts/vizChart.dart';
import 'package:techviz/model/chart.dart';
import 'package:techviz/model/chartData.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/processor/processorRepositoryFactory.dart';
import 'package:techviz/repository/remoteRepository.dart';
import 'package:techviz/stats.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';


class ProcessorUserStatsRepository extends IRemoteRepository<dynamic>{


  List<Chart> GetChartsAll(){
    var  _listOfCharts = List<Chart>();

    _listOfCharts.add(Chart(title: 'Chart 1 User', statsView: StatsView.Today, statsType: StatsType.User, chartType: ChartType.Pie, source: 'source 1'));
    _listOfCharts.add(Chart(title: 'Chart 1 Team', statsView: StatsView.Today, statsType: StatsType.Team, chartType: ChartType.Pie, source: 'source 1'));

//    _listOfCharts.add(Chart(title: 'Chart 1 User', statsView: StatsView.Today, statsType: StatsType.User, chartType: ChartType.Pie, source: 'source 1'));
//    _listOfCharts.add(Chart(title: 'Chart 1 User', statsView: StatsView.Today, statsType: StatsType.User, chartType: ChartType.Pie, source: 'source 1'));
//    _listOfCharts.add(Chart(title: 'Chart 1 User', statsView: StatsView.Today, statsType: StatsType.User, chartType: ChartType.Pie, source: 'source 1'));
//    _listOfCharts.add(Chart(title: 'Chart 1 User', statsView: StatsView.Today, statsType: StatsType.User, chartType: ChartType.Pie, source: 'source 1'));


    return _listOfCharts;
  }

  List<ChartData> GetChartData(String source){
    var list = [ChartData('AvgTimeAvailable', 1),
    ChartData('AvgTasksPerHour', 1),
    ChartData('AvgResponseTime', 1),
    ChartData('AvgCompletionTime', 1),
    ChartData('AvgTimeAvailable', 1)];

    String insertSpaces(String columnName) {
      columnName = columnName.split(RegExp("(?=[A-Z])")).join(" ");
      return columnName;
    }

    return List<ChartData>();
  }




  @override
  Future fetch() {
    print('Fetching '+this.toString());

    Completer _completer = Completer<void>();

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

    _completer.complete();

    return _completer.future;
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

}