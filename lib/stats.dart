import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:techviz/components/VizAlert.dart';
import 'package:techviz/components/VizButton.dart';
import 'package:techviz/components/stepper/VizStepperButton.dart';
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
  Map<int, Widget> _charts;
  bool _isLoading = false;
  int _idxToLoad;
  List<Widget> stepsToAdd;

  @override
  void initState() {
    super.initState();
    _statsPresenter = StatsPresenter(this);
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedViewType == null) {
      var column = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          VizButton(
              title: "Today's Stats",
              onTap: () {
                _onStatTypeTap(StatsView.Today);
              }),
          VizButton(
              title: "This Week's Stats",
              onTap: () {
                _onStatTypeTap(StatsView.Week);
              }),
          VizButton(
              title: "This Month's Stats",
              onTap: () {
                _onStatTypeTap(StatsView.Month);
              })
        ],
      );

      var padding = Padding(child: column, padding: EdgeInsets.all(20));

      return Center(child: padding);
    }

    var title = _selectedViewType == StatsView.Today ? "Today's Stats" : (_selectedViewType == StatsView.Week ? "Week's Stats" : "Month's Stats");


    var titleWidget = Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 22.0));
    var backBtn = IconButton(icon: Icon(Icons.backspace), color: Colors.grey, iconSize: 30.0, onPressed: () {
      setState(() {
        _idxToLoad = 0;
        _selectedViewType = null;
      });
    });


    var header = Stack(children: <Widget>[
      Align(child: backBtn, alignment: Alignment.centerLeft),
      Align(child: titleWidget, alignment: Alignment.center),
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

    var _stepsRow = Row(
      children: stepsToAdd,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
    );

    Column chartContainer;
    if (_isLoading) {
      var loadindWidget = Padding(child: CircularProgressIndicator(), padding: EdgeInsets.only(top: 15.0));
      chartContainer = Column(
        children: <Widget>[header, loadindWidget],
      );
    }
    else{
      chartContainer = Column(
        children: <Widget>[header, Expanded(child: _charts[_idxToLoad]), _stepsRow],
      );
    }

    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Container(
        child: Row(
          children: <Widget>[
            Expanded(
              child: SwipeDetector(
                child: chartContainer,
                onSwipeLeft: () {
                  if (_idxToLoad >= stepsToAdd.length - 1)
                    _idxToLoad = -1;
                  _idxToLoad++;
                  _stepsRowTap(_idxToLoad);
                },
                onSwipeRight: () {
                  if (_idxToLoad <= 0)
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
  void onLoaded(Map<int, Widget> charts) {
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
      _idxToLoad = i;
    });
  }

  @override
  void onError(dynamic error) {
    VizAlert.Show(context, error.toString());
  }
}
