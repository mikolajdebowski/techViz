import 'dart:async';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/remoteRepository.dart';

class UserGeneralInfoRepository implements IRepository<dynamic> {
  IRemoteRepository remoteRepository;

  UserGeneralInfoRepository({this.remoteRepository});

  @override
  Future fetch() {
    assert(this.remoteRepository != null);
    return this.remoteRepository.fetch();
  }

  @override
  Future listen() {
    throw UnimplementedError();
  }
}
