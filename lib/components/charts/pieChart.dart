/// Simple pie chart example.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:techviz/components/charts/IVizChart.dart';

class SimplePieChart extends StatelessWidget implements IVizChart{
  final List<charts.Series> seriesList;
  final bool animate;

  SimplePieChart(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {
    return new charts.PieChart<dynamic>(
        seriesList,
        animate: animate,
        defaultRenderer: new charts.ArcRendererConfig<dynamic>(
        arcRendererDecorators: [new charts.ArcLabelDecorator<dynamic>(
          insideLabelStyleSpec: new charts.TextStyleSpec(fontSize: 12, // size in Pts.
              color: charts.MaterialPalette.black),
        )]));
  }

  @override
  void load() {
    // TODO: implement load
  }

}

/// Sample linear data type.
class LinearSales {
  final num percent;

  LinearSales(this.percent);
}