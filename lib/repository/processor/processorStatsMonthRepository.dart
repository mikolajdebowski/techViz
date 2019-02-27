import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:flutter/services.dart';
import 'package:techviz/components/charts/vizChart.dart';
import 'package:techviz/repository/remoteRepository.dart';


class ProcessoStatsMonthRepository extends IRemoteRepository<dynamic>{

  String personalAxisName = 'Personal';
  String teamAxisName = 'Team Avg';

  @override
  Future fetch() async {
    print('Fetching '+this.toString());

    ChartData extractDataFromValues(List<String> columnNames, String columnName, dynamic values, String label){
      return ChartData(columnName, num.parse(values[columnNames.indexOf(columnName)] as String), label);
    }

    Completer<Map<int,List<ChartData>>> _completer = Completer<Map<int,List<ChartData>>>();

    var futureUser = rootBundle.loadString('assets/json/UserStatsCurrentMonth.json');
    var futureTeam = rootBundle.loadString('assets/json/TeamStatsCurrentMonth.json');

    Future.wait([futureUser, futureTeam]).then((List<String> json){
      var jsonUser = json[0];
      var jsonTeam = json[1];

      Map<String,dynamic> decodedUser = jsonDecode(jsonUser) as Map<String,dynamic>;
      Map<String,dynamic> decodedTeam = jsonDecode(jsonTeam) as Map<String,dynamic>;

      List<dynamic> rowsUser = decodedUser['Rows'] as List<dynamic>;
      List<String> columnNamesUser = (decodedUser['ColumnNames'] as String).split(',');

      List<dynamic> rowsTeam = decodedTeam['Rows'] as List<dynamic>;
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


      Map<int,List<ChartData>> mapToReturn = Map<int,List<ChartData>>();
      mapToReturn[0] = chartTimeAvailable;
      mapToReturn[1] = tasksPerHourAvailable;
      mapToReturn[2] = avgRespTime;
      mapToReturn[3] = completionTimes;
      mapToReturn[4] = tasksEscalated;
      mapToReturn[5] = percentTasksEscalated;

      _completer.complete(mapToReturn);
    });

    return _completer.future;
  }


}