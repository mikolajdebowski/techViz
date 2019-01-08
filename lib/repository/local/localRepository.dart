import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:techviz/repository/local/taskTable.dart';
import 'package:techviz/repository/local/userTable.dart';

class LocalRepository {

  Database db;
  String path;

  static final LocalRepository _singleton = new LocalRepository._internal();
  factory LocalRepository() {
    return _singleton;
  }

  LocalRepository._internal();

  bool isOpen(){
    return db.isOpen;
  }

  Future open() async {

    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, "techviz.db");

    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {

          TaskTable.create(db);

          UserTable.create(db);

          await db.execute('''
            create table TaskStatus ( 
                TaskStatusID INT PRIMARY KEY,
                TaskStatusDescription TEXT NOT NULL
                )
            ''');

          await db.execute('''
            create table TaskType ( 
                TaskTypeID INT PRIMARY KEY,
                TaskTypeDescription TEXT NOT NULL,
                RoleID NUMERIC
                )
            ''');

          await db.execute('''
            create table Role ( 
                UserRoleID INT NOT NULL,
                UserRoleName TEXT NOT NULL
                )
            ''');

          await db.execute('''
            create table UserRole ( 
                UserID TEXT NOT NULL,
                UserRoleID INT NOT NULL
                )
            ''');


          await db.execute('''
            create table UserStatus ( 
                UserStatusID TEXT NOT NULL,
                Description TEXT NOT NULL,
                IsOnline INTEGER NOT NULL
                )
            ''');

          await db.execute('''
            create table Section ( 
                SectionID TEXT NOT NULL
                )
            ''');

          await db.execute('''
            create table UserSection ( 
                SectionID TEXT NOT NULL,
                UserID TEXT NOT NULL
                )
            ''');

        });
  }

  Future<int> insert(String table, Map<String, dynamic> values) async {
    int id = await db.insert(table, values);
    return id;
  }

  Future close() async => db.close();


  Future dropDatabase() async {
    await this.close();
    await deleteDatabase(path);
  }
}
