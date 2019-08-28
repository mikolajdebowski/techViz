import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:techviz/repository/local/escalationPathTable.dart';
import 'package:techviz/repository/local/roleTable.dart';
import 'package:techviz/repository/local/taskTable.dart';
import 'package:techviz/repository/local/taskTypeTable.dart';
import 'package:techviz/repository/local/taskUrgencyTable.dart';
import 'package:techviz/repository/local/userTable.dart';

import 'taskStatusTable.dart';
import 'userSectionTable.dart';

abstract class ILocalRepository{
  Database get db;
}

class LocalRepository implements ILocalRepository{
  @override
  Database db;
  
  String path;

  static final LocalRepository _singleton = LocalRepository._internal();
  factory LocalRepository() {
    return _singleton;
  }

  LocalRepository._internal();

  bool isOpen(){
    return db.isOpen;
  }

  Future open() async {

    String databasesPath = await getDatabasesPath();
    path = join(databasesPath, "techviz.db");

    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {

          UserTable(this).create(db);
          UserSectionTable(this).create(db);
          TaskTable(this).create(db);
          TaskTypeTable(this).create(db);
          TaskStatusTable(this).create(db);
          EscalationPathTable(this).create(db);


          //REVISE BELOW THIS
          TaskUrgencyTable.create(db);
          RoleTable().create(db);


          await db.execute('''
            create table UserRole ( 
                UserID TEXT NOT NULL,
                UserRoleID INT NOT NULL
                )
            ''');


          await db.execute('''
            create table UserStatus ( 
                UserStatusID INT NOT NULL,
                Description TEXT NOT NULL,
                IsOnline INTEGER NOT NULL
                )
            ''');

          await db.execute('''
            create table Section ( 
                SectionID TEXT NOT NULL
                )
            ''');
        });
  }

  Future<int> insert(String table, Map<String, dynamic> values) {
    return db.insert(table, values);
  }

  Future close() async => db.close();


  Future dropDatabase() async {
    await close();
    await deleteDatabase(path);
  }


}
