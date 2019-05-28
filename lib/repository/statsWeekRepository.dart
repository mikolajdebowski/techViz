import 'dart:async';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/remoteRepository.dart';

class StatsWeekRepository implements IRepository<dynamic> {
  IRemoteRepository remoteRepository;

  StatsWeekRepository({this.remoteRepository});

  @override
  Future fetch() {
    assert(remoteRepository != null);
    return remoteRepository.fetch();
  }
}
