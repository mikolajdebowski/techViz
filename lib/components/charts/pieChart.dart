import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'IVizChart.dart';

class SimplePieChart extends StatelessWidget implements IVizChart{
  final List<charts.Series> seriesList;
  final bool animate;

  const SimplePieChart(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {

    final _defaultLayoutConfig = LayoutConfig(
      topMarginSpec: MarginSpec.fromPixel(minPixel: 10),
      bottomMarginSpec: MarginSpec.fromPixel(minPixel: 10),
      leftMarginSpec: MarginSpec.fromPixel(minPixel: 10),
      rightMarginSpec: MarginSpec.fromPixel(minPixel: 10),
    );

    return charts.PieChart<dynamic>(
        seriesList,
        animate: animate,
        defaultRenderer: charts.ArcRendererConfig<dynamic>(
        arcRendererDecorators: [ charts.ArcLabelDecorator<dynamic>(
          insideLabelStyleSpec:  charts.TextStyleSpec(fontSize: 12, color: charts.MaterialPalette.black),
        )]),
        layoutConfig: _defaultLayoutConfig,
      );
  }

  @override
  void load() {
    // TODO(rmathias): implement load
  }

}

/// Sample linear data type.
class LinearSales {
  final num percent;

  LinearSales(this.percent);
}