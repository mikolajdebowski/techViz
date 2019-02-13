import 'package:charts_common/common.dart';
import 'package:flutter/material.dart';
import 'package:techviz/components/charts/pieChart.dart';

/// Bar chart example
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:techviz/components/charts/groupedBarChart.dart';
import 'package:techviz/components/charts/stackedHorizontalBarChart.dart';
import 'package:techviz/components/charts/vizChart.dart';
import 'package:techviz/components/vizLegend.dart';
import 'package:techviz/model/chart.dart';


abstract class IChartPresenter{
  void onLoaded(Widget widget);
}

class ChartPresenter{
  IChartPresenter _view;

  ChartPresenter(IChartPresenter view){
    this._view = view;
  }

  void load(List<Chart> charts, int idx){

    //load from whatever
    //depends on type of, create an especific chart (simplepiechart, whatever)
    //based on id load correct graph

    Widget returnWidget1 = Container(width: 150, height: 150,child: buildChart(charts[0]));
    Widget returnWidget2 = Container(width: 150, height: 150,child: buildChart(charts[1]));

    var row = Row(
      children: <Widget>[returnWidget1, returnWidget2],
    );

    _view.onLoaded(row);
  }

  Widget buildChart(Chart chart){
    if(chart.chartType == ChartType.Pie){
      return buildPieChart(chart.source);
    }
    else if(chart.chartType == ChartType.VerticalBar || chart.chartType == ChartType.HorizontalBar){
      return buildBarChart(chart.source);
    }
    else {
      return Text('not implemented');
    }
  }

  Widget buildBarChart(String id){

    //load from whatever

    final todayStatsA = [
      DataStats('Personal', num.parse('3')),
      DataStats('AAA', num.parse('6')),
      DataStats('EEE', num.parse('9'))
    ];

    var seriesToBuild = [
      Series<DataStats, String>(
          id: 'Team Avg',
          domainFn: (DataStats stats, _) => stats.name,
          measureFn: (DataStats stats, _) => stats.value,
          data: todayStatsA,
          labelAccessorFn: (DataStats stats, _){
            return '${stats.value.toString()}';
          }
      )];

    return GroupedBarChart(seriesToBuild);
  }


  Widget buildPieChart(String id){

    //load from whatever

    final todayStatsA = [
      DataStats('Personal', num.parse('3')),
      DataStats('AAA', num.parse('6')),
      DataStats('EEE', num.parse('9'))
    ];

    var seriesToBuild = [
      Series<DataStats, String>(
          id: 'Team Avg',
          domainFn: (DataStats stats, _) => stats.name,
          measureFn: (DataStats stats, _) => stats.value,
          data: todayStatsA,
          labelAccessorFn: (DataStats stats, _){
            return '${stats.value.toString()}';
          }
      )];

    return SimplePieChart(seriesToBuild);
  }
}


class DataStats {
  final String name;
  final num value;

  DataStats(this.name, this.value);
}