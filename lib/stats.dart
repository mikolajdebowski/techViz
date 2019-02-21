import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:techviz/components/VizAlert.dart';
import 'package:techviz/components/charts/vizChart.dart';
import 'package:techviz/components/stepper/VizStepperButton.dart';
import 'package:techviz/presenter/statsPresenter.dart';

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
  Map<int, List<Widget>> _charts;
  bool _isLoading = false;
  int _idxToLoad;
  String subTitle = '';

  @override
  void initState() {
    super.initState();
    _statsPresenter = StatsPresenter(this);
  }

  @override
  Widget build(BuildContext context) {
    void _onStatTypeTap(StatsView selected) {
      setState(() {
        _selectedViewType = selected;
        _isLoading = true;
      });
      _statsPresenter.load(_selectedViewType);
    }

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

    var title = _selectedViewType == StatsView.Today ? "Todays's Stats": (_selectedViewType == StatsView.Week ? "Week's Stats" : "Month's Stats");

    var subHeader = Text(subTitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 14.0));
    var titleWidget = Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 22.0));

    var backBtn = RaisedButton(child: Text('Back'), onPressed: (){
      setState(() {
        _selectedViewType = null;
      });
    });

    var header = Row(children: <Widget>[backBtn, Padding(
      padding: const EdgeInsets.only(left: 40.0),
      child: titleWidget,
    )]);


    List<Widget> stepsToAdd = [];
    for(int i = 0; i<=5; i++){
      var btnToAdd = Padding(
          padding: EdgeInsets.all(5),
          child: VizStepperButton(
              title: (i+1).toString(),
              onTap: () {
                _stepsRowTap(i);
              }));
      stepsToAdd.add(btnToAdd);
    }
    var _stepsRow = Row(children: stepsToAdd, mainAxisAlignment: MainAxisAlignment.center);


    Widget _innerWidget = Container();
    Column chartContainer;
    if(_isLoading){
      _innerWidget = CircularProgressIndicator();
      chartContainer = Column(
        children: <Widget>[header, subHeader, _innerWidget, _stepsRow],
      );
    }
    else if(_charts!=null && _charts.length>0 && _idxToLoad!=null)
    {
      _innerWidget = Row(children: _charts[_idxToLoad]);
      chartContainer = Column(
        children: <Widget>[header, subHeader, Expanded(child: _innerWidget), _stepsRow],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: chartContainer,
    );
  }


  @override
  void onLoaded(Map<int, List<Widget>> charts) {
    setState(() {
      _charts = charts;
//      _isLoading = false;
    });

    Future.delayed(Duration(seconds: 1), (){
      _isLoading = false;
      _stepsRowTap(0);
    });
  }
  
  void _stepsRowTap(int i) {
    setState(() {
      if(_charts!=null && _charts.length>0){
        subTitle = (_charts[i][0] as VizChart).title.toString();
      }

      _idxToLoad = i;
    });
  }

  @override
  void onError(dynamic error) {
    VizAlert.Show(context, error.toString());
  }

}