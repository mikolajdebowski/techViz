/// Bar chart example
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class GroupedBarChart extends StatelessWidget {
  List<charts.Series<dynamic, String>> seriesList;
  final bool animate;

  GroupedBarChart(this.seriesList, {this.animate});


  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
      barGroupingType: charts.BarGroupingType.grouped,
    );
  }
}

class AvgTasksCompleted {
  final String name;
  final double avrTasksCompleted;

  AvgTasksCompleted(this.name, this.avrTasksCompleted);
}