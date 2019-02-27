import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:flutter/services.dart';
import 'package:techviz/components/charts/vizChart.dart';
import 'package:techviz/repository/processor/processorLiveTable.dart';
import 'package:techviz/repository/processor/processorRepositoryFactory.dart';
import 'package:techviz/repository/remoteRepository.dart';


class ProcessorStatsTodayRepository extends ProcessorLiveTable<dynamic> implements IRemoteRepository<dynamic>{

  String personalAxisName = 'Personal';
  String teamAxisName = 'Team Avg';

  @override
  Future fetch() async {
    Completer<Map<int,List<ChartData>>> _completer = Completer<Map<int,List<ChartData>>>();
    print('Fetching '+this.toString());

    tableID = LiveTableType.TECHVIZ_MOBILE_USER_TODAY_STATS.toString();
    List<dynamic> futureUserToday = await super.fetch() as List<dynamic>;
    List<String> columnNamesUser = futureUserToday[0] as List<String>;
    List<dynamic> rowsUser = futureUserToday[1] as List<dynamic>;

    //TODO: once team stats is faster uncomment
//    tableID = LiveTableType.TECHVIZ_MOBILE_TEAM_TODAY_STATS.toString();
//    List<dynamic> futureTeamToday = await super.fetch();
//    List<String> columnNamesTeam =  futureTeamToday[0] as List<String>;
//    List<dynamic> rowsTeam = futureTeamToday[1] as List<dynamic>;

    // Graph 1 time available for tasks... TimeAvailableForTaskHr and AvgTimeAvailableForTaskHr
    List<ChartData> chartTimeAvailable = [];

    // Graph 2 tasks per logged in hour... TasksPerLoggedInHour and AvgTasksPerLoggedInHour
    List<ChartData> tasksPerHourAvailable = [];

//      Map<String,dynamic> decodedUser = jsonDecode(jsonUser) as Map<String,dynamic>;
//      Map<String,dynamic> decodedTeam = jsonDecode(jsonTeam) as Map<String,dynamic>;

//      List<dynamic> rowsUser = decodedUser['Rows'] as  List<dynamic>;
//      List<String> columnNamesUser = (decodedUser['ColumnNames'] as String).split(',');

//      List<dynamic> rowsTeam = decodedTeam['Rows'] as List<dynamic>;
//      List<String> columnNamesTeam = (decodedTeam['ColumnNames'] as String).split(',');
    // average response times... AvgResponseTime and AvgResponseTime
    List<ChartData> avgRespTime = [];

    // average completion times... AvgCompletionTime and AvgCompletionTime
    List<ChartData> completionTimes = [];

    // tasks escalated... TasksEscalated and AvgTasksEscalated
    List<ChartData> tasksEscalated = [];

    // percent of tasks escalated... PercentEscalated and AvgPercentEscalated
    List<ChartData> percentTasksEscalated = [];

    // col names for USER: AvgCompletionTime, AvgResponseTime, EscalatedCount, PctEscalated, TasksPerLoggedInHour, TimeAvailableForTaskHr
    if(rowsUser[0]['Values'].length as int > 0){
      chartTimeAvailable.add(extractDataFromValues(columnNamesUser, 'TimeAvailableForTaskHr', rowsUser[0]['Values'], personalAxisName));
      tasksPerHourAvailable.add(extractDataFromValues(columnNamesUser, 'TasksPerLoggedInHour', rowsUser[0]['Values'], personalAxisName));
      avgRespTime.add(extractDataFromValues(columnNamesUser, 'AvgResponseTime', rowsUser[0]['Values'], personalAxisName));
      completionTimes.add(extractDataFromValues(columnNamesUser, 'AvgCompletionTime', rowsUser[0]['Values'], personalAxisName));
      tasksEscalated.add(extractDataFromValues(columnNamesUser, 'EscalatedCount', rowsUser[0]['Values'], personalAxisName));
      percentTasksEscalated.add(extractDataFromValues(columnNamesUser, 'PctEscalated', rowsUser[0]['Values'], personalAxisName));
    }


    // col names for TEAM: AvgCompletionTime, AvgResponseTime, AvgEscalatedCount, AvgPctEscalated, AvgTasksPerHour, AvgTimeAvailableHr
    //TODO: once team stats is faster uncomment
//    if(rowsTeam[0]['Values'].length as int > 0){
//      chartTimeAvailable.add(extractDataFromValues(columnNamesTeam, 'AvgTimeAvailableHr', rowsTeam[0]['Values'], teamAxisName));
//      tasksPerHourAvailable.add(extractDataFromValues(columnNamesTeam, 'AvgTasksPerHour', rowsTeam[0]['Values'], teamAxisName));
//      avgRespTime.add(extractDataFromValues(columnNamesTeam, 'AvgResponseTime', rowsTeam[0]['Values'], teamAxisName));
//      completionTimes.add(extractDataFromValues(columnNamesTeam, 'AvgCompletionTime', rowsTeam[0]['Values'], teamAxisName));
//      tasksEscalated.add(extractDataFromValues(columnNamesTeam, 'AvgEscalatedCount', rowsTeam[0]['Values'], teamAxisName));
//      percentTasksEscalated.add(extractDataFromValues(columnNamesTeam, 'AvgPctEscalated', rowsTeam[0]['Values'], teamAxisName));
//    }

    Map<int,List<ChartData>> mapToReturn = Map<int,List<ChartData>>();
    mapToReturn[0] = chartTimeAvailable;
    mapToReturn[1] = tasksPerHourAvailable;
    mapToReturn[2] = avgRespTime;
    mapToReturn[3] = completionTimes;
    mapToReturn[4] = tasksEscalated;
    mapToReturn[5] = percentTasksEscalated;

    _completer.complete(mapToReturn);

    return _completer.future;
  }


  ChartData extractDataFromValues(List<String> columnNames, String columnName, dynamic values, String label){
    if(values[columnNames.indexOf(columnName)] != ''){
      return ChartData(columnName, num.parse(values[columnNames.indexOf(columnName)] as String), label);
    }
    else{
      return ChartData(columnName, 0, label);
    }
  }

}