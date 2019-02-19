import 'dart:async';
import 'package:techviz/model/user.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/remoteRepository.dart';

class UserRepository implements IRepository<User>{

  IRemoteRepository remoteRepository;
  UserRepository({this.remoteRepository});

  @override
  Future fetch() {
    assert(this.remoteRepository!=null);
    return this.remoteRepository.fetch();
  }
}