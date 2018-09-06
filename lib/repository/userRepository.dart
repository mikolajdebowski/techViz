import 'dart:async';
import 'package:techviz/model/user.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/localRepository.dart';
import 'package:techviz/repository/rabbitmq/channel/remoteChannel.dart';
import 'package:techviz/repository/remoteRepository.dart';

class UserRepository implements IRepository<User>{

  IRemoteRepository remoteRepository;
  IRemoteChannel remoteChannel;
  UserRepository({this.remoteRepository});

  Future<User> getUser() async {
    LocalRepository localRepo = LocalRepository();

    String sql = "SELECT UserID, UserRoleID, UserStatusID FROM User";
    List<Map<String, dynamic>> queryResult = await localRepo.rawQuery(sql);

    if(queryResult.length>0){
      Map<String, dynamic> userMap = queryResult.first;
      var u = User(
        UserID: userMap['UserID'] as String,
        UserRoleID: userMap['UserID'] as String,
        UserStatusID: userMap['UserStatusID'] as String,
      );
      return u;
    }

    throw Exception('User was not found');
  }

  @override
  Future fetch() {
    assert(this.remoteRepository!=null);
    return this.remoteRepository.fetch();
  }

  @override
  Future listen(){
    throw new UnimplementedError('Unimplemented method');
  }

  @override
  Future submit(User object) {
    assert(this.remoteChannel!=null);
    return this.remoteChannel.submit(object);
  }
}