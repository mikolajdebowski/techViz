
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
    mapToReturn[0] = [VizChart(GlobalKey(), data[0], ChartType.HorizontalBar, parser: convertToHours)];//, VizChart(GlobalKey(), [data['Team'][0]], ChartType.VerticalBar)];
    //mapToReturn[1] = [VizChart(GlobalKey(), [data['User'][1]], ChartType.VerticalBar), VizChart(GlobalKey(), [data['Team'][1]], ChartType.VerticalBar)];
    //mapToReturn[2] = [VizChart(GlobalKey(), [data['User'][2]], ChartType.VerticalBar), VizChart(GlobalKey(), [data['Team'][2]], ChartType.VerticalBar)];
    //mapToReturn[3] = [VizChart(GlobalKey(), [data['User'][3]], ChartType.VerticalBar), VizChart(GlobalKey(), [data['Team'][3]], ChartType.VerticalBar)];
    //mapToReturn[4] = [VizChart(GlobalKey(), [data['User'][4]], ChartType.VerticalBar), VizChart(GlobalKey(), [data['Team'][4]], ChartType.VerticalBar)];
    //mapToReturn[5] = [VizChart(GlobalKey(), [data['User'][5]], ChartType.Pie), VizChart(GlobalKey(), [data['Team'][5]], ChartType.Pie)];

    _view.onLoaded(mapToReturn);

  }
}