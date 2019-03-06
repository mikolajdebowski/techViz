import 'dart:async';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/remoteRepository.dart';

class UserSkillsRepository implements IRepository<dynamic> {
  IRemoteRepository remoteRepository;

  UserSkillsRepository({this.remoteRepository});

  @override
  Future fetch() {
    assert(this.remoteRepository != null);
    return this.remoteRepository.fetch();
  }
}
