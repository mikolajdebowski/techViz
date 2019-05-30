import 'dart:async';
import 'package:techviz/model/user.dart';
import 'package:techviz/repository/async/UserRouting.dart';
import 'package:techviz/repository/local/userTable.dart';


abstract class IUserRemoteRepository{
  Future<Map> fetch();
  Future<List<Map>> usersBySectionsByTaskCount();
}

class UserRepository {

  IUserRemoteRepository remoteRepository;
  IUserRouting userRouting;
  IUserTable localTable;

  UserRepository(this.remoteRepository, this.userRouting, this.localTable){
    assert(remoteRepository!=null);
    assert(userRouting!=null);
    assert(localTable!=null);
  }

  Future fetch() {
    assert(remoteRepository!=null);
    return remoteRepository.fetch();
  }

  Future<User> getUser(String userID){
    return localTable.getUser(userID);
  }

  Future<int> update(String userID, {String roleID, String statusID}) {
    Map<String, dynamic> toSend = <String, dynamic>{};
    toSend['userID'] = userID;
    if (roleID != null) {
      toSend['userRoleID'] = roleID;
    }
    if (statusID != null) {
      toSend['userStatusID'] = statusID;
    }

    Completer _completer = Completer<int>();

    userRouting.publishMessage(toSend).then((dynamic r) {
      localTable.update(userID, statusID: statusID, roleID: roleID).then((int result) {
        _completer.complete(result);
      }).catchError((dynamic error) {
        _completer.completeError(error);
      });
    }).catchError((dynamic publishError) {
      _completer.completeError(publishError);
    });
    return _completer.future;
  }

  Future<List<Map>> usersBySectionsByTaskCount(){
    return remoteRepository.usersBySectionsByTaskCount();
  }




}