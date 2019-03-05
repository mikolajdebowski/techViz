import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:techviz/components/VizAlert.dart';
import 'package:techviz/components/charts/vizChart.dart';
import 'package:techviz/components/stepper/VizStepperButton.dart';
import 'package:techviz/components/vizLegend.dart';
import 'package:techviz/presenter/statsPresenter.dart';
import 'package:swipedetector/swipedetector.dart';

class Stats extends StatefulWidget {
  Stats();

  @override
  State<StatefulWidget> createState() => StatsState();
}

enum StatsView { Today, Week, Month }

enum StatsType { User, Team }

class StatsState extends State<Stats> implements IStatsPresenter {
  StatsView _selectedViewType;
  StatsPresenter _statsPresenter;
  Map<int, ChartDataGroup> _charts;
  bool _isLoading = false;
  int _idxToLoad;
  String subTitle = '';
  List<Widget> stepsToAdd;

  @override
  void initState() {
    super.initState();
    _statsPresenter = StatsPresenter(this);
  }

  @override
  Widget build(BuildContext context) {

    if (_selectedViewType == null) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
              child: Text('Today'),
              onPressed: () {
                _onStatTypeTap(StatsView.Today);
              }),
          RaisedButton(
              child: Text('Week'),
              onPressed: () {
                _onStatTypeTap(StatsView.Week);
              }),
          RaisedButton(
              child: Text('Month'),
              onPressed: () {
                _onStatTypeTap(StatsView.Month);
              })
        ],
      ));
    }


    var title = _selectedViewType == StatsView.Today
        ? "Todays's Stats"
        : (_selectedViewType == StatsView.Week ? "Week's Stats" : "Month's Stats");

    var subHeader = Text(subTitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 14.0));
    var titleWidget = Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 22.0));

    var backBtn = RaisedButton(
        child: Text('Back'),
        onPressed: () {
          setState(() {
            _idxToLoad = 0;
            _selectedViewType = null;
          });
        });

    var header = Row(children: <Widget>[
      backBtn,
      Padding(
        padding: const EdgeInsets.only(left: 80.0),
        child: titleWidget,
      )
    ]);

    stepsToAdd = [];
    for (int i = 0; i <= 6; i++) {
      var btnToAdd = Padding(
          padding: EdgeInsets.all(5),
          child: VizStepperButton(
              isActive: _idxToLoad == i,
              title: (i + 1).toString(),
              onTap: () {
                _stepsRowTap(i);
              }));
      stepsToAdd.add(btnToAdd);
    }
    var _stepsRow = Row(children: stepsToAdd, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,);
    
    var legendModel = [
      VizLegendModel(Color(0xFF96CF96), 'Personal'),
      VizLegendModel(Color(0xFF175FC7), 'Team Avg'),
    ];

    Widget _innerWidget = Container();
    Row _legend = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[VizLegend(legendModel)],
    );

    Column chartContainer;
    if (_isLoading) {
      _innerWidget = CircularProgressIndicator();
      chartContainer = Column(
        children: <Widget>[header, subHeader, _innerWidget, _stepsRow],
      );
    } else if (_charts != null && _charts.length > 0 && _idxToLoad != null) {
      _innerWidget = _charts[_idxToLoad].charts;

      // for pie chart and tasks completed by day, week, month show legend
      if (_idxToLoad == 6) {
        chartContainer = Column(
          children: <Widget>[header, subHeader, _legend, Expanded(child: _innerWidget), _stepsRow],
        );
      } else {
        chartContainer = Column(
          children: <Widget>[header, subHeader, Expanded(child: _innerWidget), _stepsRow],
        );
      }
    }

    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Container(
        child: Row(
          children: <Widget>[
            Expanded(
              child: SwipeDetector(
                child: chartContainer,
                onSwipeLeft: () {
                  if(_idxToLoad >= stepsToAdd.length-1)
                    _idxToLoad = -1;
                  _idxToLoad++;
                  _stepsRowTap(_idxToLoad);
                },
                onSwipeRight: () {
                  if(_idxToLoad <= 0)
                    _idxToLoad = stepsToAdd.length;
                  _idxToLoad--;
                  _stepsRowTap(_idxToLoad);
                },
                swipeConfiguration: SwipeConfiguration(
                    verticalSwipeMinVelocity: 100.0,
                    verticalSwipeMinDisplacement: 50.0,
                    verticalSwipeMaxWidthThreshold: 100.0,
                    horizontalSwipeMaxHeightThreshold: 50.0,
                    horizontalSwipeMinDisplacement: 50.0,
                    horizontalSwipeMinVelocity: 200.0),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onStatTypeTap(StatsView selected) {
    setState(() {
      _selectedViewType = selected;
      _isLoading = true;
    });
    _statsPresenter.load(_selectedViewType);
  }



  @override
  void onLoaded(Map<int, ChartDataGroup> charts) {
    setState(() {
      _charts = charts;
    });

    Future.delayed(Duration(seconds: 1), () {
      _isLoading = false;
      _stepsRowTap(0);
    });
  }

  void _stepsRowTap(int i) {
    setState(() {
      if (_charts != null && _charts.length > 0) {
        subTitle = _charts[i].title;
      }
      _idxToLoad = i;
    });
  }

  @override
  void onError(dynamic error) {
    VizAlert.Show(context, error.toString());
  }
}
