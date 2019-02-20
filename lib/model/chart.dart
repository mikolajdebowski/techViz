
import 'package:techviz/components/charts/vizChart.dart';
import 'package:techviz/stats.dart';

class Chart{
  final String title;
  final ChartType chartType;
  final StatsType statsType;
  final StatsView statsView;
  final String source;

  Chart({this.title, this.statsView, this.statsType, this.chartType, this.source});
}