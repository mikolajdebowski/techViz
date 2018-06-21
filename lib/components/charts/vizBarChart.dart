import 'dart:async';

import 'package:flutter/material.dart';
import 'package:techviz/components/vizActionBar.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class VizBarChart extends StatefulWidget {
  VizBarChart({Key key}) : super(key: key);

  @override
  _VizBarChartState createState() => _VizBarChartState();
}

class ClicksPerYear {
  final String year;
  final int clicks;
  final charts.Color color;

  ClicksPerYear(this.year, this.clicks, Color color)
      : this.color = new charts.Color(
      r: color.red, g: color.green, b: color.blue, a: color.alpha);
}

class _VizBarChartState extends State<VizBarChart> {
  int _counter = 0;

  _VizBarChartState(){
    const oneSec = const Duration(seconds:1);
    new Timer.periodic(oneSec, (Timer t) {
      setState(() {
        _counter = _counter+13;
      });
    });
  }


  @override
  Widget build(BuildContext context) {

    var data = [
      new ClicksPerYear('2016', 12, Colors.red),
      new ClicksPerYear('2017', 42, Colors.yellow),
      new ClicksPerYear('2018', _counter, Colors.green),
    ];

    var series = [
      new charts.Series(
        domainFn: (ClicksPerYear clickData, _) => clickData.year,
        measureFn: (ClicksPerYear clickData, _) => clickData.clicks,
        colorFn: (ClicksPerYear clickData, _) => clickData.color,
        id: 'Clicks',
        data: data,
      ),
    ];

    var chart = new charts.BarChart(
      series,
      animate: true,
    );

    var chartWidget = new Padding(
      padding: new EdgeInsets.all(32.0),
      child: new SizedBox(
        height: 200.0,
        child: chart,
      ),
    );


    return Scaffold(
      backgroundColor: Colors.black,
      appBar: ActionBar(title: 'Bar', titleColor: Colors.blue),
      body: Center(
        child: chartWidget,
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          setState(() {
            _counter = _counter+10;
          });
        },
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
