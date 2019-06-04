import 'dart:async';
import 'package:techviz/model/user.dart';
import 'package:techviz/repository/local/localRepository.dart';

import 'localTable.dart';


abstract class IUserTable {
  Future<int> insertUser(Map map);
  Future<int> updateUser(String userID, {String statusID, String roleID});
  Future<User> getUser(String userID);
}

class UserTable extends LocalTable implements IUserTable{
  UserTable(ILocalRepository localRepo): super(localRepo: localRepo){
    createSQL = '''
            create table User ( 
                UserID TEXT NOT NULL PRIMARY KEY,
                UserName TEXT NOT NULL,
                UserRoleID TEXT NOT NULL,
                UserStatusID TEXT NOT NULL,
                StaffID TEXT NOT NULL
                )
            ''';
  }

  @override
  Future<int> insertUser(Map map){
    return localRepo.db.insert('User', map);
  }

  @override
  Future<int> updateUser(String userID, {String statusID, String roleID}) {
    Map<String,dynamic> values = <String,dynamic>{};
    if(statusID!=null){
      values['UserStatusID'] = statusID;
    }
    if(roleID!=null){
      values['UserRoleID'] = roleID;
    }

    return localRepo.db.update('User', values, where: "UserID = '$userID'");
  }

  @override
  Future<User> getUser(String userID) async {
    LocalRepository localRepo = LocalRepository();

    String sql = "SELECT UserID, UserName, UserRoleID, UserStatusID, StaffID FROM User WHERE UserID = ?";
    List<Map<String, dynamic>> queryResult = await localRepo.db.rawQuery(sql, [userID].toList());

    if(queryResult.isNotEmpty){
      return User.fromMap(queryResult.first);
    }

    throw Exception('User was not found');
  }
}