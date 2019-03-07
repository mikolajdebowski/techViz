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

  static Future<User> updateStatusID(String userID, String userStatusID) async {
    LocalRepository localRepo = LocalRepository();

    await localRepo.db.rawUpdate('UPDATE User SET UserStatusID = ? WHERE UserID = ?', [userStatusID, userID].toList());

    return getUser(userID);
  }

  static Future<User> getUser(String userID) async {
    LocalRepository localRepo = LocalRepository();

    String sql = "SELECT UserID, UserName, UserRoleID, UserStatusID, StaffID FROM User WHERE UserID = ?";
    List<Map<String, dynamic>> queryResult = await localRepo.db.rawQuery(sql, [userID].toList());

    if(queryResult.length>0){
      return User.fromMap(queryResult.first);
    }

    throw Exception('User was not found');
  }

}