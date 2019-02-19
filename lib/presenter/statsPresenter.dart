
import 'package:flutter/cupertino.dart';
import 'package:techviz/components/charts/vizChart.dart';
import 'package:techviz/repository/processor/processorStatsWeekRepository.dart';
import 'package:techviz/repository/processor/processorStatsMonthRepository.dart';
import 'package:techviz/repository/processor/processorStatsTodayRepository.dart';
import 'package:techviz/repository/statsMonthRepository.dart';
import 'package:techviz/repository/statsTodayRepository.dart';
import 'package:techviz/repository/statsWeekRepository.dart';
import 'package:techviz/stats.dart';

abstract class IStatsPresenter{
  void onLoaded(Map<int, List<Widget>> widget);
}

class StatsPresenter {
  IStatsPresenter _view;

  StatsPresenter(IStatsPresenter view) {
    this._view = view;
  }

  StatsTodayRepository get statsTodayRepository {
    return StatsTodayRepository(remoteRepository: ProcessoStatsTodayRepository());
  }

  StatsWeekRepository get statsWeekRepository {
    return StatsWeekRepository(remoteRepository: ProcessorStatsWeekRepository());
  }

  StatsMonthRepository get statsMonthRepository {
    return StatsMonthRepository(remoteRepository: ProcessoStatsMonthRepository());
  }

  Future load(StatsView view) async {

    Map<int, List<ChartData>> data;

    if(view == StatsView.Today){
      data = await statsTodayRepository.fetch() as Map<int, List<ChartData>>;
    }
    else if(view == StatsView.Week){
      data = await statsWeekRepository.fetch() as Map<int, List<ChartData>>;
    }
    else if(view == StatsView.Month){
      data = await statsMonthRepository.fetch() as Map<int, List<ChartData>>;
    }

    String convertToHours(num original){
      Duration timeAvailable = new Duration(seconds: int.parse(original.toString()) );
      return '${timeAvailable.inHours} hr ${timeAvailable.inMinutes%60} min';
    }

    Map<int, List<Widget>> mapToReturn = Map<int, List<Widget>>();
    mapToReturn[0] = [VizChart(GlobalKey(), data[0], ChartType.HorizontalBar, 'Time Available for Tasks', parser: convertToHours)];
    mapToReturn[1] = [VizChart(GlobalKey(), data[1], ChartType.HorizontalBar, 'Tasks per Logged in Hour')];
    mapToReturn[2] = [VizChart(GlobalKey(), data[2], ChartType.HorizontalBar, 'Avg Response')];
    mapToReturn[3] = [VizChart(GlobalKey(), data[3], ChartType.HorizontalBar, 'Completion Times')];
    mapToReturn[4] = [VizChart(GlobalKey(), data[4], ChartType.HorizontalBar, 'Tasks Escalated')];

    mapToReturn[5] = [VizChart(GlobalKey(), [data[5][0]], ChartType.Pie, 'Percent of Tasks Escalated'),
                      VizChart(GlobalKey(), [data[5][1]], ChartType.Pie, 'Percent of Tasks Escalated')];
    _view.onLoaded(mapToReturn);

  }


  String parseName(String columnName) {
    columnName = columnName.split(RegExp("(?=[A-Z])")).join(" ");
    return columnName;
  }
}