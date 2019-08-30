import 'dart:async';
import 'package:techviz/model/user.dart';
import 'package:techviz/repository/async/UserRouting.dart';
import 'package:techviz/repository/local/userTable.dart';


abstract class IUserRemoteRepository{
  Future<Map> fetch();
  Future<List<Map>> usersBySectionsByTaskCount();
  Future<List<Map>> teamAvailabilitySummary();
}

class UserRepository {

  IUserRemoteRepository remoteRepository;
  IUserRouting userRouting;
  IUserTable localTable;

  UserRepository(this.remoteRepository, this.userRouting, this.localTable){
    assert(remoteRepository!=null);
  }

  Future fetch() async {
    assert(remoteRepository!=null);
    Map user = await remoteRepository.fetch();
    return localTable.insertUser(user);
  }

  Future<User> getUser(String userID){
    return localTable.getUser(userID);
  }

  Future<List<Map>> usersBySectionsByTaskCount(){
    return remoteRepository.usersBySectionsByTaskCount();
  }

  Future<List<Map>> teamAvailabilitySummary(){
    return remoteRepository.teamAvailabilitySummary();
  }
}