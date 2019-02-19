import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:techviz/components/charts/groupedBarChart.dart';
import 'package:techviz/components/charts/pieChart.dart';
import 'package:techviz/components/charts/stackedHorizontalBarChart.dart';

class VizChart extends StatefulWidget {
  final List<ChartData> chartData;
  final ChartType chartType;
  final Function parser;
  final String title;

  VizChart(Key key, this.chartData, this.chartType, this.title, {this.parser}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VizChartState();
}

class VizChartState extends State<VizChart> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget returnWidget;

    if (widget.chartType == ChartType.Pie) {
      returnWidget = buildPieChart(widget.chartData);
    } else if (widget.chartType == ChartType.VerticalBar) {
      returnWidget = buildBarChart(widget.chartData);
    } else if (widget.chartType == ChartType.HorizontalBar) {
      returnWidget = buildStackedHorizontalBarChart(widget.chartData);
    } else {
      returnWidget = Text('not implemented');
    }

    return Expanded(child:returnWidget);
  }

  // vertical bar isFirst
  Widget buildBarChart(List<ChartData> data) {
    var seriesToBuild = [
      Series<ChartData, String>(
          id: 'id',
          domainFn: (ChartData stats, _) => stats.name,
          measureFn: (ChartData stats, _) => stats.value,
          data: data,
          labelAccessorFn: (ChartData stats, _) {
            return '${stats.value.toString()}';
          })
    ];

    return GroupedBarChart(seriesToBuild);
  }

  // horizontal bar
  Widget buildStackedHorizontalBarChart(List<ChartData> data) {
    var seriesToBuild = [
      Series<ChartData, String>(
          id: 'id',
          domainFn: (ChartData stats, _) => stats.label,
          measureFn: (ChartData stats, _) => stats.value,
          data: data,
          labelAccessorFn: (ChartData stats, _) {
            if (widget.parser != null) {
              return widget.parser(stats.value) as String;
            }
            return '${stats.value.toString()}';
          })
    ];

    return StackedHorizontalBarChart(seriesToBuild);
  }

  // pie charts
  Widget buildPieChart(List<ChartData> data) {

    if(data.length == 1){
      var chartData = new ChartData('', 100 - num.parse(data[0].value.toString()), '');
      data.add(chartData);
    }

    var seriesToBuild = [
      Series<ChartData, String>(
          id: 'id',
          domainFn: (ChartData stats, _) => stats.label,
          measureFn: (ChartData stats, _) => stats.value,
          data: data,
          labelAccessorFn: (ChartData stats, _) {
            return '${stats.value.round()}%';
          })
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(child: SimplePieChart(seriesToBuild)),
        Text(data[0].label),
      ],
    );
  }
}

enum ChartType { Pie, VerticalBar, HorizontalBar }

class ChartData {
  final String name;
  final num value;
  final String label;

  ChartData(this.name, this.value, this.label);
}
