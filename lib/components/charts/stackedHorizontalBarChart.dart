/// Bar chart example
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class StackedHorizontalBarChart extends StatelessWidget {
  final List<charts.Series<dynamic, String>> seriesList;
  final bool animate;

  const StackedHorizontalBarChart(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {
    // For horizontal bar charts, set the [vertical] flag to false.
    return charts.BarChart(
      seriesList,
      animate: animate,
      barGroupingType: charts.BarGroupingType.stacked,
      vertical: false,

      domainAxis: charts.OrdinalAxisSpec(
          renderSpec: charts.SmallTickRendererSpec(

            // Tick and Label styling here.
              labelStyle: charts.TextStyleSpec(
                  fontSize: 18, // size in Pts.
                  color: charts.MaterialPalette.black),

              // Change the line colors to match text color.
              lineStyle: charts.LineStyleSpec(
                  color: charts.MaterialPalette.black))),

    barRendererDecorator: charts.BarLabelDecorator<String>(
        insideLabelStyleSpec: charts.TextStyleSpec(fontSize: 12, // size in Pts.
                  color: charts.MaterialPalette.black)),


      /// Assign a custom style for the measure axis.
      primaryMeasureAxis: charts.NumericAxisSpec(
          renderSpec: charts.GridlineRendererSpec(

            // Tick and Label styling here.
              labelStyle: charts.TextStyleSpec(
                  fontSize: 0, // size in Pts.
                  color: charts.MaterialPalette.black),

              // Change the line colors to match text color.
              lineStyle: charts.LineStyleSpec(
                  color: charts.MaterialPalette.black))),
    );
  }
}

/// Sample ordinal data type.
class TodayStats {
  final String name;
  final num value;

  TodayStats(this.name, this.value);
}