import 'dart:async';
import 'dart:math';

import 'package:charts_common/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:techviz/components/charts/vizChart.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/stats.dart';

abstract class IStatsPresenter {
  void onLoaded(Map<int, ChartDataGroup> widget);
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
    } else if (view == StatsView.Week) {
      futureToCall = Repository().statsWeekRepository.fetch();
    } else if (view == StatsView.Month) {
      futureToCall = Repository().statsMonthRepository.fetch();
    }

    futureToCall.then((dynamic dataReturned) {
      Map<int, List<ChartData>> data = dataReturned as Map<int, List<ChartData>>;

      String convertToHours(num original) {
        Duration timeAvailable = new Duration(seconds: int.parse(original.round().toString()));
        return '${timeAvailable.inHours} hr ${timeAvailable.inMinutes % 60} min';
      }

      Map<int, ChartDataGroup> mapToReturn = Map<int, ChartDataGroup>();
      mapToReturn[0] = ChartDataGroup(Row(children: [VizChart(GlobalKey(), data[0], ChartType.HorizontalBar, parser: convertToHours)]), 'Time Available for Tasks');
      mapToReturn[1] = ChartDataGroup(Row(children: [VizChart(GlobalKey(), data[1], ChartType.HorizontalBar )]), 'Tasks per Logged in Hour');
      mapToReturn[2] = ChartDataGroup(Row(children: [VizChart(GlobalKey(), data[2], ChartType.HorizontalBar, parser: convertToHours)]), 'Avg Response Time');
      mapToReturn[3] = ChartDataGroup(Row(children: [VizChart(GlobalKey(), data[3], ChartType.HorizontalBar, parser: convertToHours)]), 'Avg Completion Times');
      mapToReturn[4] = ChartDataGroup(Row(children: [VizChart(GlobalKey(), data[4], ChartType.HorizontalBar, )]), 'Tasks Escalated');

      if (data[5].length == 1) {
        mapToReturn[5] = ChartDataGroup(Row(children: [VizChart(GlobalKey(), [data[5][0]], ChartType.Pie)]), 'Percent of Tasks Escalated');

      } else if (data[5].length == 2) {
        mapToReturn[5] = ChartDataGroup(Row(children: [
          VizChart(GlobalKey(), [data[5][0]], ChartType.Pie),
          VizChart(GlobalKey(), [data[5][1]], ChartType.Pie)
        ]), 'Percent of Tasks Escalated');
      }

      if (data[6] != null && data[6].length > 0) {
        List<Widget> _children = [];
        data[6].forEach((ChartData chartData) {
          var rng = new Random();
          var fakeData = [chartData, ChartData('', rng.nextInt(6) + 1, '', color: MaterialPalette.blue.shadeDefault.darker)];

          var chart = VizChart(GlobalKey(), fakeData, ChartType.VerticalBar);

          _children.add(chart);
        });

        //var gvCharts = GridView.count(crossAxisCount: 3, children:_children, shrinkWrap: true, physics: BouncingScrollPhysics());
        var gvCharts = Row(children: _children);
        mapToReturn[6] = ChartDataGroup(gvCharts, 'Tasks Completed by Type');
      }

      _view.onLoaded(mapToReturn);
    }).catchError((dynamic error) {
      _view.onError(error);
    });
  }
}
