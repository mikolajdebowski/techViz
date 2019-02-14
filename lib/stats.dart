import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

    var title = _selectedViewType == StatsView.Today ? "Todays's": (_selectedViewType == StatsView.Week ? "Week's" : "Month's");
    var titleWidget = Text(title, textAlign: TextAlign.center);
    var backBtn = RaisedButton(child: Text('Back'), onPressed: (){
      setState(() {
        _selectedViewType = null;
      });
    });

    var header = Row(children: <Widget>[backBtn, titleWidget]);


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
    var _stepsRow = Row(children: stepsToAdd, crossAxisAlignment: CrossAxisAlignment.center);


    Widget _innerWidget = Container();
    if(_isLoading){
      _innerWidget = CircularProgressIndicator();
    }
    else if(_charts!=null && _charts.length>0 && _idxToLoad!=null)
    {
      _innerWidget = Row(children: _charts[_idxToLoad]);
    }

    var chartContainer = Column(
        children: <Widget>[header, _innerWidget, _stepsRow],
      );

    return chartContainer;
  }


  @override
  void onLoaded(Map<int, List<Widget>> charts) {
    setState(() {
      _charts = charts;
      _isLoading = false;

    });

    Future.delayed(Duration(seconds: 1), (){
      _stepsRowTap(0);
    });
  }
  
  void _stepsRowTap(int i) {
    setState(() {
      _idxToLoad = i;
    });
  }

}








//  // Create one series with sample hard coded data.
//  static List<charts.Series<LinearSales, num>> _createPieChartData(dynamic value) {
//
//    final todayStats = [
//      LinearSales(100 - num.parse(value.toString())),
//      LinearSales(num.parse(value.toString())),
//    ];
//
//
//    return [
//      new charts.Series<LinearSales, num>(
//          id: 'todayStats',
//          domainFn: (LinearSales sales, _) => sales.percent,
//          measureFn: (LinearSales sales, _) => sales.percent,
//          data: todayStats,
//          labelAccessorFn: (LinearSales row, _) => '${row.percent.round()}%'
//      )
//    ];
//  }
//
//  /// Create series list with multiple series
//  static List<charts.Series<AvgTasksCompleted, String>> _createDataForTasks(List<dynamic> tasksCompletedByType) {
//
//    final averageData = <AvgTasksCompleted>[];
//
//    tasksCompletedByType.forEach((dynamic element) {
////      print(element);
//      String desc = element['TaskDescription'].toString();
//      double avrTasksCompleted = double.parse(element['AvgTasksCompleted'].toString());
//      AvgTasksCompleted task = AvgTasksCompleted(desc, avrTasksCompleted);
//      averageData.add(task);
//    });
//
//
//
//    final personalData = [
//      new AvgTasksCompleted('Change Light', 2.0),
//      new AvgTasksCompleted('Jackpot', 1.0),
//      new AvgTasksCompleted('Printer', 3.0),
//    ];
//
//    return [
//      new charts.Series<AvgTasksCompleted, String>(
//        id: 'PersonalData',
//        domainFn: (AvgTasksCompleted sales, _) => sales.name,
//        measureFn: (AvgTasksCompleted sales, _) => sales.avrTasksCompleted,
//        data: personalData,
//      ),
//      new charts.Series<AvgTasksCompleted, String>(
//        id: 'AvrData',
//        domainFn: (AvgTasksCompleted sales, _) => sales.name,
//        measureFn: (AvgTasksCompleted sales, _) => sales.avrTasksCompleted,
//        data: averageData,
//      ),
//    ];
//  }
//
//
//  static List<charts.Series<TodayStats, String>> _createData( String columnName, dynamic val1, dynamic val2) {
//
////    print('columnName ${columnName}, value ${val1}, value ${val2}');
//
//    final todayStatsA = [
//      TodayStats('Personal', num.parse(val1.toString())),
//    ];
//
//    final todayStatsB = [
//      TodayStats('Team Avg', num.parse(val2.toString())),
//    ];
//
//    return [
//      new charts.Series<TodayStats, String>(
//          id: 'Team Avg',
//          domainFn: (TodayStats stats, _) => stats.name,
//          measureFn: (TodayStats stats, _) => stats.value,
//          data: todayStatsB,
//          labelAccessorFn: (TodayStats sales, _){
//            if(columnName == 'TimeAvailable'){
//              Duration timeAvailable = new Duration(seconds: int.parse(sales.value.toString()) );
//              return '${timeAvailable.inHours} hr ${timeAvailable.inMinutes%60} min';
//            }else{
//              return '${sales.value.toString()}';
//            }
//          }
//
//      ),
//      new charts.Series<TodayStats, String>(
//          id: 'Personal',
//          domainFn: (TodayStats sales, _) => sales.name,
//          measureFn: (TodayStats sales, _) => sales.value,
//          data: todayStatsA,
//          labelAccessorFn: (TodayStats sales, _){
//            if(columnName == 'TimeAvailable'){
//              Duration timeAvailable = new Duration(seconds: int.parse(sales.value.toString()) );
//              return '${timeAvailable.inHours} hr ${timeAvailable.inMinutes%60} min';
//            }else{
//              return '${sales.value.toString()}';
//            }
//          }
//      ),
//    ];
//  }

//    setState(() {
//      userStatsMap.forEach((columnName, dynamic v) {
//
//        Widget chart;
//        double radius = 133.0;
//
//        if(columnName.contains('Percent')){
//          chart = Row(
//            mainAxisAlignment: MainAxisAlignment.center,
//            children: <Widget>[
//              Column(children: <Widget>[
//                Container(
//                  width: radius,
//                  height: radius,
//                  child: SimplePieChart(_createPieChartData(v)),
//                ),
//                Text('Personal')
//              ],),
//              Column(children: <Widget>[
//                Container(
//                  width: radius,
//                  height: radius,
//                  child: SimplePieChart(_createPieChartData(teamStatsMap[columnName])),
//                ),
//                Text('Team Avg')
//              ],),
//            ],);
//
//        }else if(columnName.contains('TasksCompletedByType')){
//          chart =  Row(children: <Widget>[
//            Container(
//              width: 257,
//              height: 140,
//              child: GroupedBarChart(_createDataForTasks(userStatsMap['TasksCompletedByType'] as List<dynamic>)),
//            ),
//            Padding(
//              padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
//              child: VizLegend(),
//            ),
//          ],);
//        }else{
//          chart = StackedHorizontalBarChart(_createData(columnName, v, teamStatsMap[columnName]));
//        }
//
//        var step = VizStep(
//            title: insertSpaces(columnName),
//            content: Container(
//              width: 150,
//              height: 150,
//              child: chart,
//            ),
//            isActive: true);
//
//        my_steps.add(step);
//
//      });
//
//      for (int i = 0; i < my_steps.length; i += 1)
//        my_steps[i].isActive = false;
//
//      my_steps[0].isActive = true;
//    });

//
//void _onStatPress(String selection){
//  setState(() {
//    _selectedStat = selection;
//  });
//}
//
//if(_selectedStat==null){
//List<String> stats = ["Today", "This Week", "This Month"];
//
//return Center(child: Column(
//children: <Widget>[
//MaterialButton(child: Text(stats[0]), onPressed: (){
//_onStatPress(stats[0]);
//}),
//MaterialButton(child: Text(stats[1]), onPressed: (){
//_onStatPress(stats[1]);
//}),
//MaterialButton(child: Text(stats[2]), onPressed: (){
//_onStatPress(stats[2]);
//})
//],
//));
//}
//
//
//
//
//if(_selectedStat == 'Today'){
//
//}
//
//
//

//    Widget inner = null;
//
//    if(_listOfCharts ==null || _listOfCharts.length==0)
//      inner = Center(child: CircularProgressIndicator());
//    else Stats('  ')
//
//    return Expanded(
//      flex: 2,
//      child:
//    )
//
//
//    else return
