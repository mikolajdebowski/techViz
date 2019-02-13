
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:techviz/components/stepper/VizStepperButton.dart';
import 'package:techviz/model/chart.dart';
import 'package:techviz/presenter/chart/chartPresenter.dart';

class VizChartBuilder extends StatefulWidget {
  final List<Chart> charts;
  VizChartBuilder(Key key, this.charts) : super(key : key);

  @override
  State<StatefulWidget> createState() => VizChartBuilderState();
}

class VizChartBuilderState extends State<VizChartBuilder> implements IChartPresenter{

  bool _isLoading;
  Widget _chartWidget;
  ChartPresenter _chartPresenter;

  @override
  void initState() {
    _isLoading = true;
    _chartPresenter = ChartPresenter(this);
    _chartPresenter.load(widget.charts, 0);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void _stepsRowTap(int idx){
      _chartPresenter.load(widget.charts, idx);
    }


    if(_isLoading)
      return Center(child: CircularProgressIndicator());




    List<Widget> stepsToAdd = [];
    for(int i = 1; i<=6; i++){
      var btnToAdd = Padding(
          padding: EdgeInsets.all(5),
          child: VizStepperButton(
              title: (i).toString(),
              onTap: () {
                _stepsRowTap(i);
              }));
      stepsToAdd.add(btnToAdd);
    }
    var _stepsRow = Row(children: stepsToAdd, crossAxisAlignment: CrossAxisAlignment.center);

    return Column(
      children: <Widget>[
        _chartWidget,
        _stepsRow
      ],
    );
  }

  @override
  void onLoaded(Widget _widget) {
    setState(() {
      _isLoading = false;
      _chartWidget = _widget;
    });
  }
}

enum ChartType{
  Pie,VerticalBar,HorizontalBar
}


/*
* List<Widget> stepsToAdd = [];
    _selectedChartsToShow.forEach((final Chart chart) {
      var btnToAdd = Padding(
          padding: EdgeInsets.all(5),
          child: VizStepperButton(
              title: chart.title,
              onTap: () {
                setState(() {
                  _selectedChart = chart;
                  loadSelectedChart();
                });
              }));

      stepsToAdd.add(btnToAdd);
    });



* */