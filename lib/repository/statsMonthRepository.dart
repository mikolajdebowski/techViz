import 'dart:async';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/remoteRepository.dart';

class StatsMonthRepository implements IRepository<dynamic> {
  IRemoteRepository remoteRepository;

  StatsMonthRepository({this.remoteRepository});

  @override
  Future fetch() {
    assert(this.remoteRepository != null);
    return this.remoteRepository.fetch();
  }

  @override
  Future listen(Function callback, Function callbackError) {
    throw UnimplementedError();
  }
}
