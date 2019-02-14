import 'dart:async';
import 'package:flutter/services.dart';
import 'package:techviz/components/charts/vizChart.dart';
import 'package:techviz/model/chart.dart';
import 'package:techviz/repository/remoteRepository.dart';
import 'package:techviz/stats.dart';


class ProcessoStatsMonthRepository extends IRemoteRepository<dynamic>{

  @override
  Future fetch() async {
    print('Fetching '+this.toString());

    Completer _completer = Completer<void>();

    var data = await rootBundle.loadString('assets/json/UserStatsCurrentDay.json');
    var data2 = await rootBundle.loadString('assets/json/TeamStatsCurrentDay.json');



    _completer.complete([data,data2]);

    return _completer.future;

  }


}