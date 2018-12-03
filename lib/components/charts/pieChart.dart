/// Simple pie chart example.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class SimplePieChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SimplePieChart(this.seriesList, {this.animate});


  @override
  Widget build(BuildContext context) {
    return new charts.PieChart<dynamic>(seriesList, animate: animate,
        defaultRenderer: new charts.ArcRendererConfig<dynamic>(
        arcRendererDecorators: [new charts.ArcLabelDecorator<dynamic>()]));
  }

}

/// Sample linear data type.
class LinearSales {
  final num percent;

  LinearSales(this.percent);
}