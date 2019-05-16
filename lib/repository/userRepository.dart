import 'dart:async';
import 'package:techviz/model/user.dart';
import 'package:techviz/repository/async/UserRouting.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/local/userTable.dart';
import 'package:techviz/repository/remoteRepository.dart';

abstract class IUserRepository extends IRemoteRepository<User>{
  Future allUsers();
}

class UserRepository implements IRepository<User>{

  IUserRepository remoteRepository;
  UserRepository({this.remoteRepository});

  @override
  Future fetch() {
    assert(this.remoteRepository!=null);
    return this.remoteRepository.fetch();
  }

  Future Update(String userID, {String roleID, String statusID}){

    Map<String,dynamic> toSend = Map<String,dynamic>();
    toSend['userID'] = userID;
    if(roleID!=null){
      toSend['userRoleID'] = roleID;
    }
    if(statusID!=null){
      toSend['userStatusID'] = statusID;
    }

    Completer<bool> _completer = Completer<bool>();

    UserRouting().PublishMessage(toSend).then((dynamic r) {
      UserTable.update(userID, statusID: statusID, roleID: roleID).then((int result) {
        _completer.complete(true);
      }).catchError((dynamic error) {
        _completer.completeError(error);
      });
    }).catchError((dynamic publishError){
      _completer.completeError(publishError);
    });


    return _completer.future;
  }

  Future<List<User>> allUsers(){
    Completer<List<User>> _completer = Completer<List<User>>();

    this.remoteRepository.allUsers().then((dynamic result){
      List<Map> listMap = result as List<Map>;
      List<User> listUsers = listMap.map((Map map)=> User.fromMap(map)).toList();
      _completer.complete(listUsers);
    });
    return _completer.future;

  }

}