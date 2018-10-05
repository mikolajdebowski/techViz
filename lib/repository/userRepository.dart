import 'dart:async';
import 'package:techviz/model/user.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/rabbitmq/channel/iRemoteChannel.dart';
import 'package:techviz/repository/remoteRepository.dart';

class UserRepository implements IRepository<User>{

  IRemoteRepository remoteRepository;
  IRemoteChannel remoteChannel;
  UserRepository({this.remoteRepository});



  @override
  Future fetch() {
    assert(this.remoteRepository!=null);
    return this.remoteRepository.fetch();
  }

  @override
  Future listen(){
    throw new UnimplementedError('Unimplemented method');
  }
}