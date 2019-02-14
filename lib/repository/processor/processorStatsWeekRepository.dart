import 'dart:async';
import 'package:flutter/services.dart';
import 'package:techviz/repository/remoteRepository.dart';

class ProcessorStatsWeekRepository extends IRemoteRepository<dynamic>{

  @override
  Future fetch() async {
    Completer _completer = Completer<void>();

    var data = await rootBundle.loadString('assets/json/UserStatsCurrentDay.json');
    var data2 = await rootBundle.loadString('assets/json/TeamStatsCurrentDay.json');
    _completer.complete([data,data2]);

    return _completer.future;

  }
}