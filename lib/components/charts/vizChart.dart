import 'package:charts_flutter/flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:techviz/components/charts/groupedBarChart.dart';
import 'package:techviz/components/charts/pieChart.dart';
import 'package:techviz/components/charts/stackedHorizontalBarChart.dart';

enum ChartType { Pie, VerticalBar, HorizontalBar }

class ChartData {
  final String name;
  final num value;
  final String label;
  final Color color;

  ChartData(this.name, this.value, this.label, {this.color});
}

class VizChart extends StatelessWidget {
  final List<ChartData> chartData;
  final ChartType chartType;
  final Function parser;

  VizChart(Key key, this.chartData, this.chartType, {this.parser}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Widget returnWidget;

    if (chartType == ChartType.Pie) {
      returnWidget = buildPieChart(chartData);
    } else if (chartType == ChartType.VerticalBar) {
      returnWidget = buildBarChart(chartData);
    } else if (chartType == ChartType.HorizontalBar) {
      returnWidget = buildStackedHorizontalBarChart(chartData);
    } else {
      returnWidget = Text('not implemented');
    }
    return returnWidget;
  }

  // vertical bar
  Widget buildBarChart(List<ChartData> data) {
    var seriesToBuild = [
      Series<ChartData, String>(
          id: 'id',
          domainFn: (ChartData stats, _) => stats.value.toString(),
          measureFn: (ChartData stats, _) => stats.value,
          fillColorFn: (ChartData stats, _) {
            if(stats.color!=null){
              return stats.color as Color;
            }
          },
          data: data,
          labelAccessorFn: (ChartData stats, _) {
            return '${stats.value.toString()}';
          })
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(child: GroupedBarChart(seriesToBuild)),
        Text(data[0].label)
      ],
    );
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
            if (parser != null) {
              return parser(stats.value) as String;
            }
            return '${stats.value.toString()}';
          },
        fillColorFn: (ChartData stats, _) {
          if(stats.color!=null){
            return stats.color as Color;
          }
        }),
    ];
    return StackedHorizontalBarChart(seriesToBuild);
  }

  // pie charts
  Widget buildPieChart(List<ChartData> data) {

    if(data.length == 1){
      var chartData = new ChartData('', 100 - num.parse(data[0].value.toString()), '', color: MaterialPalette.green.shadeDefault.darker);
      data.add(chartData);
    }

    var seriesToBuild = [
      Series<ChartData, String>(
          id: 'id',
          domainFn: (ChartData stats, _) => stats.label,
          measureFn: (ChartData stats, _) => stats.value,
          data: data,
          labelAccessorFn: (ChartData stats, _) {
            if(stats.name.length > 1)
              return '${stats.value.round()}%';
            else
              return '';
          },
          colorFn: (ChartData stats, _) {
            return stats.color as Color;
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

