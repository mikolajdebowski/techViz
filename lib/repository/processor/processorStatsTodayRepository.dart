import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:flutter/services.dart';
import 'package:techviz/components/charts/vizChart.dart';
import 'package:techviz/repository/processor/processorLiveTable.dart';
import 'package:techviz/repository/remoteRepository.dart';


class ProcessorStatsTodayRepository extends ProcessorLiveTable<dynamic> implements IRemoteRepository<dynamic>{

  String personalAxisName = 'Personal';
  String teamAxisName = 'Team Avg';

  // TODO: just mock data for demo
  @override
  Future fetch() async {
    print('Fetching '+this.toString());

    Completer<Map<int,List<ChartData>>> _completer = Completer<Map<int,List<ChartData>>>();

    var futureUser = rootBundle.loadString('assets/json/UserStatsCurrentDay.json');
    var futureTeam = rootBundle.loadString('assets/json/TeamStatsCurrentDay.json');
    var futureTasks = rootBundle.loadString('assets/json/TeamTasksCompletedCurrentDay.json');



    Future.wait([futureUser, futureTeam, futureTasks]).then((List<String> json){
      var jsonUser = json[0];
      var jsonTeam = json[1];
      var jsonTasks = json[2];

      Map<String,dynamic> decodedUser = jsonDecode(jsonUser);
      Map<String,dynamic> decodedTeam = jsonDecode(jsonTeam);
      Map<String,dynamic> decodedTasksByType = jsonDecode(jsonTasks);

      List<dynamic> rowsUser = decodedUser['Rows'];
      List<String> columnNamesUser = (decodedUser['ColumnNames'] as String).split(',');

      List<dynamic> rowsTeam = decodedTeam['Rows'];
      List<String> columnNamesTeam = (decodedTeam['ColumnNames'] as String).split(',');

      // Graph 1 time available for tasks... TimeAvailable and AvgTimeAvailable
      List<ChartData> chartTimeAvailable = [];
      chartTimeAvailable.add(extractDataFromValues(columnNamesUser, 'TimeAvailable', rowsUser[0]['Values'], personalAxisName));
      chartTimeAvailable.add(extractDataFromValues(columnNamesTeam, 'AvgTimeAvailable', rowsTeam[0]['Values'], teamAxisName));

      // Graph 2 tasks per logged in hour... TasksPerHour and AvgTasksPerHour
      List<ChartData> tasksPerHourAvailable = [];
      tasksPerHourAvailable.add(extractDataFromValues(columnNamesUser, 'TasksPerHour', rowsUser[0]['Values'], personalAxisName));
      tasksPerHourAvailable.add(extractDataFromValues(columnNamesTeam, 'AvgTasksPerHour', rowsTeam[0]['Values'], teamAxisName));

      // average response times... AvgResponseTime and AvgResponseTime
      List<ChartData> avgRespTime = [];
      avgRespTime.add(extractDataFromValues(columnNamesUser, 'AvgResponseTime', rowsUser[0]['Values'], personalAxisName));
      avgRespTime.add(extractDataFromValues(columnNamesTeam, 'AvgResponseTime', rowsTeam[0]['Values'], teamAxisName));

      // average completion times... AvgCompletionTime and AvgCompletionTime
      List<ChartData> completionTimes = [];
      completionTimes.add(extractDataFromValues(columnNamesUser, 'AvgCompletionTime', rowsUser[0]['Values'], personalAxisName));
      completionTimes.add(extractDataFromValues(columnNamesTeam, 'AvgCompletionTime', rowsTeam[0]['Values'], teamAxisName));

      // tasks escalated... TasksEscalated and AvgTasksEscalated
      List<ChartData> tasksEscalated = [];
      tasksEscalated.add(extractDataFromValues(columnNamesUser, 'TasksEscalated', rowsUser[0]['Values'], personalAxisName));
      tasksEscalated.add(extractDataFromValues(columnNamesTeam, 'AvgTasksEscalated', rowsTeam[0]['Values'], teamAxisName));

      // percent of tasks escalated... PercentEscalated and AvgPercentEscalated
      List<ChartData> percentTasksEscalated = [];
      percentTasksEscalated.add(extractDataFromValues(columnNamesUser, 'PercentEscalated', rowsUser[0]['Values'], personalAxisName));
      percentTasksEscalated.add(extractDataFromValues(columnNamesTeam, 'AvgPercentEscalated', rowsTeam[0]['Values'], teamAxisName));





      // Tasks By Type ... TaskDescription, AvgTasksCompleted
      List<dynamic> rowsTasksByType = decodedTasksByType['Rows'];
      List<String> columnNamesTasksByType = (decodedTasksByType['ColumnNames'] as String).split(',');
      List<ChartData> chartTasksByType = [];

      rowsTasksByType.forEach((dynamic d) {
        dynamic values = d['Values'];
        String label = values[columnNamesTasksByType.indexOf("TaskDescription")];
        num value = num.parse(values[columnNamesTasksByType.indexOf("AvgTasksCompleted")].toString());
        ChartData chart = ChartData('', value, label);
        chartTasksByType.add(chart);
      });

      Map<int,List<ChartData>> mapToReturn = Map<int,List<ChartData>>();
      mapToReturn[0] = chartTimeAvailable;
      mapToReturn[1] = tasksPerHourAvailable;
      mapToReturn[2] = avgRespTime;
      mapToReturn[3] = completionTimes;
      mapToReturn[4] = tasksEscalated;
      mapToReturn[5] = percentTasksEscalated;
      mapToReturn[6] = chartTasksByType;

      _completer.complete(mapToReturn);
    });

    return _completer.future;
  }

  //TODO uncomment proper solution
//  @override
//  Future fetch() async {
//    Completer<Map<int,List<ChartData>>> _completer = Completer<Map<int,List<ChartData>>>();
//    print('Fetching '+this.toString());
//
//    tableID = LiveTableType.TECHVIZ_MOBILE_USER_TODAY_STATS.toString();
//    List<dynamic> futureUserToday = await super.fetch();
//    List<String> columnNamesUser = futureUserToday[0] as List<String>;
//    List<dynamic> rowsUser = futureUserToday[1] as List<dynamic>;
//
//    //TODO: once team stats is faster uncomment
////    tableID = LiveTableType.TECHVIZ_MOBILE_TEAM_TODAY_STATS.toString();
////    List<dynamic> futureTeamToday = await super.fetch();
////    List<String> columnNamesTeam =  futureTeamToday[0] as List<String>;
////    List<dynamic> rowsTeam = futureTeamToday[1] as List<dynamic>;
//
//    // Graph 1 time available for tasks... TimeAvailableForTaskHr and AvgTimeAvailableForTaskHr
//    List<ChartData> chartTimeAvailable = [];
//
//    // Graph 2 tasks per logged in hour... TasksPerLoggedInHour and AvgTasksPerLoggedInHour
//    List<ChartData> tasksPerHourAvailable = [];
//
//    // average response times... AvgResponseTime and AvgResponseTime
//    List<ChartData> avgRespTime = [];
//
//    // average completion times... AvgCompletionTime and AvgCompletionTime
//    List<ChartData> completionTimes = [];
//
//    // tasks escalated... TasksEscalated and AvgTasksEscalated
//    List<ChartData> tasksEscalated = [];
//
//    // percent of tasks escalated... PercentEscalated and AvgPercentEscalated
//    List<ChartData> percentTasksEscalated = [];
//
//    // col names for USER: AvgCompletionTime, AvgResponseTime, EscalatedCount, PctEscalated, TasksPerLoggedInHour, TimeAvailableForTaskHr
//    if(rowsUser[0]['Values'].length as int > 0){
//      chartTimeAvailable.add(extractDataFromValues(columnNamesUser, 'TimeAvailableForTaskHr', rowsUser[0]['Values'], personalAxisName));
//      tasksPerHourAvailable.add(extractDataFromValues(columnNamesUser, 'TasksPerLoggedInHour', rowsUser[0]['Values'], personalAxisName));
//      avgRespTime.add(extractDataFromValues(columnNamesUser, 'AvgResponseTime', rowsUser[0]['Values'], personalAxisName));
//      completionTimes.add(extractDataFromValues(columnNamesUser, 'AvgCompletionTime', rowsUser[0]['Values'], personalAxisName));
//      tasksEscalated.add(extractDataFromValues(columnNamesUser, 'EscalatedCount', rowsUser[0]['Values'], personalAxisName));
//      percentTasksEscalated.add(extractDataFromValues(columnNamesUser, 'PctEscalated', rowsUser[0]['Values'], personalAxisName));
//    }
//
//
//    // col names for TEAM: AvgCompletionTime, AvgResponseTime, AvgEscalatedCount, AvgPctEscalated, AvgTasksPerHour, AvgTimeAvailableHr
//    //TODO: once team stats is faster uncomment
////    if(rowsTeam[0]['Values'].length as int > 0){
////      chartTimeAvailable.add(extractDataFromValues(columnNamesTeam, 'AvgTimeAvailableHr', rowsTeam[0]['Values'], teamAxisName));
////      tasksPerHourAvailable.add(extractDataFromValues(columnNamesTeam, 'AvgTasksPerHour', rowsTeam[0]['Values'], teamAxisName));
////      avgRespTime.add(extractDataFromValues(columnNamesTeam, 'AvgResponseTime', rowsTeam[0]['Values'], teamAxisName));
////      completionTimes.add(extractDataFromValues(columnNamesTeam, 'AvgCompletionTime', rowsTeam[0]['Values'], teamAxisName));
////      tasksEscalated.add(extractDataFromValues(columnNamesTeam, 'AvgEscalatedCount', rowsTeam[0]['Values'], teamAxisName));
////      percentTasksEscalated.add(extractDataFromValues(columnNamesTeam, 'AvgPctEscalated', rowsTeam[0]['Values'], teamAxisName));
////    }
//
//    Map<int,List<ChartData>> mapToReturn = Map<int,List<ChartData>>();
//    mapToReturn[0] = chartTimeAvailable;
//    mapToReturn[1] = tasksPerHourAvailable;
//    mapToReturn[2] = avgRespTime;
//    mapToReturn[3] = completionTimes;
//    mapToReturn[4] = tasksEscalated;
//    mapToReturn[5] = percentTasksEscalated;
//
//    _completer.complete(mapToReturn);
//
//    return _completer.future;
//  }


  ChartData extractDataFromValues(List<String> columnNames, String columnName, dynamic values, String label){
    if(values[columnNames.indexOf(columnName)] != ''){
      return ChartData(columnName, num.parse(values[columnNames.indexOf(columnName)] as String), label);
    }
    else{
      return ChartData(columnName, 0, label);
    }
  }

}