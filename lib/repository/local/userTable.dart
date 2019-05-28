import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:techviz/model/user.dart';
import 'package:techviz/repository/local/localRepository.dart';

class UserTable{
  static Future<dynamic> create(Database db) {
    return db.execute('''
            create table User ( 
                UserID TEXT NOT NULL PRIMARY KEY,
                UserName TEXT NOT NULL,
                UserRoleID TEXT NOT NULL,
                UserStatusID TEXT NOT NULL,
                StaffID TEXT NOT NULL
                )
            ''');
  }

  static Future<int> update(String userID, {String statusID, String roleID}) async {
    LocalRepository localRepo = LocalRepository();

    Map<String,dynamic> values = <String,dynamic>{};
    if(statusID!=null){
      values['UserStatusID'] = statusID;
    }
    if(roleID!=null){
      values['UserRoleID'] = roleID;
    }

    return localRepo.db.update('User', values, where: "UserID = '$userID'");
  }

  static Future<User> updateStatusID(String userID, String userStatusID) async {
    LocalRepository localRepo = LocalRepository();

    await localRepo.db.rawUpdate('UPDATE User SET UserStatusID = ? WHERE UserID = ?', [userStatusID, userID].toList());

    return getUser(userID);
  }

  static Future<User> getUser(String userID) async {
    LocalRepository localRepo = LocalRepository();

    String sql = "SELECT UserID, UserName, UserRoleID, UserStatusID, StaffID FROM User WHERE UserID = ?";
    List<Map<String, dynamic>> queryResult = await localRepo.db.rawQuery(sql, [userID].toList());

    if(queryResult.isNotEmpty){
      return User.fromMap(queryResult.first);
    }

    throw Exception('User was not found');
  }

}