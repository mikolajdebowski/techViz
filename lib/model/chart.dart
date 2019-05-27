
import 'package:techviz/components/charts/vizChart.dart';
import 'package:techviz/ui/stats.dart';

// TODO(rmathias): THIS CLASS SHOULD NOT BE IN MODEL FOLDER

class Chart{
  final String title;
  final ChartType chartType;
  final StatsType statsType;
  final StatsView statsView;
  final String source;

  Chart({this.title, this.statsView, this.statsType, this.chartType, this.source});
}