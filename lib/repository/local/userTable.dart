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
                UserStatusID TEXT NOT NULL
                )
            ''');
  }

  static Future<User> updateStatusID(String userID, String userStatusID) async {
    LocalRepository localRepo = LocalRepository();

    int updated = await localRepo.db.rawUpdate('UPDATE User SET UserStatusID = ? WHERE UserID = ?', [userStatusID, userID].toList());

    return getUser(userID);
  }

  static Future<User> getUser(String userID) async {
    LocalRepository localRepo = LocalRepository();

    String sql = "SELECT UserID, UserRoleID, UserStatusID FROM User WHERE UserID = ?";
    List<Map<String, dynamic>> queryResult = await localRepo.db.rawQuery(sql, [userID].toList());

    if(queryResult.length>0){
      Map<String, dynamic> userMap = queryResult.first;
      var u = User(
        UserID: userMap['UserID'] as String,
        UserRoleID: int.parse(userMap['UserRoleID'].toString()),
        UserStatusID: int.parse(userMap['UserStatusID'].toString()),
      );
      return u;
    }

    throw Exception('User was not found');
  }

}