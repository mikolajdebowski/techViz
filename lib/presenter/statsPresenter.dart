
import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:techviz/components/charts/vizChart.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/stats.dart';

abstract class IStatsPresenter{
  void onLoaded(Map<int, List<Widget>> widget);
  void onError(dynamic error);
}

class StatsPresenter {
  IStatsPresenter _view;

  StatsPresenter(IStatsPresenter view) {
    this._view = view;
  }

  void load(StatsView view) {
    Future futureToCall = null;

    if (view == StatsView.Today) {
      futureToCall = Repository().statsTodayRepository.fetch();
    }
    else if (view == StatsView.Week) {
      futureToCall = Repository().statsWeekRepository.fetch();
    }
    else if (view == StatsView.Month) {
      futureToCall = Repository().statsMonthRepository.fetch();
    }

    futureToCall.then((dynamic dataReturned) {
      Map<int, List<ChartData>> data = dataReturned as Map<int, List<ChartData>>;

      String convertToHours(num original) {
        Duration timeAvailable = new Duration(seconds: int.parse(original.round().toString()));
        return '${timeAvailable.inHours} hr ${timeAvailable.inMinutes % 60} min';
      }

      Map<int, List<Widget>> mapToReturn = Map<int, List<Widget>>();
      mapToReturn[0] = [VizChart(
          GlobalKey(), data[0], ChartType.HorizontalBar, 'Time Available for Tasks', parser: convertToHours)
      ];

      mapToReturn[1] = [VizChart(GlobalKey(), data[1], ChartType.HorizontalBar, 'Tasks per Logged in Hour')];
      mapToReturn[2] = [VizChart(GlobalKey(), data[2], ChartType.HorizontalBar, 'Avg Time Response', parser: convertToHours)];
      mapToReturn[3] = [VizChart(GlobalKey(), data[3], ChartType.HorizontalBar, 'Avg Completion Times', parser: convertToHours)];
      mapToReturn[4] = [VizChart(GlobalKey(), data[4], ChartType.HorizontalBar, 'Tasks Escalated')];

      if(data[5].length == 1){
        mapToReturn[5] = [VizChart(GlobalKey(), [data[5][0]], ChartType.Pie, 'Percent of Tasks Escalated')];
      } else if(data[5].length == 2){
        mapToReturn[5] = [VizChart(GlobalKey(), [data[5][0]], ChartType.Pie, 'Percent of Tasks Escalated'),
        VizChart(GlobalKey(), [data[5][1]], ChartType.Pie, 'Percent of Tasks Escalated')];
      }


      if(data[6] != null && data[6].length > 0){

        mapToReturn[6] =[];
        data[6].forEach((ChartData chartData) {

          chartData.isPersonal = true;

          var rng = new Random();
          var fakeData = [chartData, ChartData('', rng.nextInt(6) + 1, '', isPersonal: false)];
          var chart = VizChart(GlobalKey(), fakeData, ChartType.VerticalBar, 'Tasks Completed by Type');

          mapToReturn[6].add(chart);
        });

      }

      _view.onLoaded(mapToReturn);
    }).catchError((dynamic error) {
      _view.onError(error);
    });
  }
}