import 'dart:async';
import 'dart:math';
import 'package:charts_common/common.dart' as charts_common;
import 'package:flutter/widgets.dart';
import 'package:techviz/components/charts/vizChart.dart';
import 'package:techviz/components/vizLegend.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/ui/stats.dart';

abstract class IStatsPresenter {
  void onLoaded(Map<int, Widget> widget);
  void onError(dynamic error);
}

class StatsPresenter {
  IStatsPresenter _view;

  StatsPresenter(IStatsPresenter view) {
    this._view = view;
  }

  void load(StatsView view) {
    Future futureToCall;

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
        return '${timeAvailable.inHours} hr ${timeAvailable.inMinutes % 60} min ${timeAvailable.inSeconds % 60} sec';
      }

      Map<int, Widget> mapToReturn = Map<int, Widget>();
      mapToReturn[0] = Column(children: <Widget>[Text('Time Available for Tasks'), Expanded(child: VizChart(GlobalKey(), data[0], ChartType.HorizontalBar, parser: convertToHours))]);
      mapToReturn[1] = Column(children: <Widget>[Text('Tasks per Logged in Hour'), Expanded(child: VizChart(GlobalKey(), data[1], ChartType.HorizontalBar ))]);
      mapToReturn[2] = Column(children: <Widget>[Text('Avg Response Time'), Expanded(child: VizChart(GlobalKey(), data[2], ChartType.HorizontalBar, parser: convertToHours))]);
      mapToReturn[3] = Column(children: <Widget>[Text('Avg Completion Times'), Expanded(child: VizChart(GlobalKey(), data[3], ChartType.HorizontalBar, parser: convertToHours))]);
      mapToReturn[4] = Column(children: <Widget>[Text('Tasks Escalated'), Expanded(child: VizChart(GlobalKey(), data[4], ChartType.HorizontalBar, ))]);//, );

      List<Widget> _chart5Children = data[5].map((ChartData cd)=> VizChart(GlobalKey(), [cd], ChartType.Pie)).toList();
      mapToReturn[5] = Column(children: <Widget>[Text('Percent of Tasks Escalated'), Expanded(child: GridView.count(childAspectRatio: 1.3, shrinkWrap: true, crossAxisCount: 2, children: _chart5Children),)]);

      if (data[6] != null && data[6].length > 0) {
        List<Widget> _children = [];
        data[6].forEach((ChartData chartData) {
          var rng = new Random();
          var fakeData = [chartData, ChartData('', rng.nextInt(6) + 1, '', color: charts_common.MaterialPalette.green.shadeDefault.darker)];
          var chart = VizChart(GlobalKey(), fakeData, ChartType.VerticalBar);
          //var chart = Text(chartData.label);

          _children.add(chart);
        });

        var legendModel = [
          VizLegendModel(Color(0xFF96CF96), 'Personal'),
          VizLegendModel(Color(0xFF388E3C), 'Team Avg'),
        ];

        Stack _header = Stack(
          children: <Widget>[ Align(child: Text('Tasks Completed by Type'), alignment: Alignment.center,), Align(child: VizLegend(legendModel), alignment: Alignment.centerRight,)],
        );

        var gvCharts = Column(children: <Widget>[_header, Expanded(child: GridView.count(crossAxisCount: 3, children: _children))]);
        mapToReturn[6] = gvCharts;
      }

      _view.onLoaded(mapToReturn);
    }).catchError((dynamic error) {
      _view.onError(error);
    });
  }
}