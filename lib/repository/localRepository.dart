import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalRepository {

  Database db;
  String path;

  static final LocalRepository _singleton = new LocalRepository._internal();
  factory LocalRepository() {
    return _singleton;
  }

  LocalRepository._internal();

  Future open() async {

    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, "techviz.db");

    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
            create table Task ( 
                _Dirty INT NOT NULL,
                _Version INT NOT NULL,
                _ID TEXT, 
                EventID INT,
                MachineID TEXT,
                TaskStatusID INT NOT NULL,
                TaskTypeID INT,
                TaskCreated DATETIME,
                TaskAssigned DATETIME,
                TaskNote TEXT,
                TaskResponded DATETIME,
                Amount NUMERIC,
                Location TEXT,
                EventDesc TEXT,
                PlayerID TEXT,
                PlayerFirstName TEXT,
                PlayerLastName TEXT,
                PlayerTier TEXT,
                PlayerTierColorHex TEXT)
            ''');

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
            create table User ( 
                UserID TEXT NOT NULL,
                UserName TEXT NOT NULL,
                UserRoleID TEXT NOT NULL,
                UserStatusID TEXT NOT NULL
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

  Future<List<Map<String, dynamic>>> rawQuery(String query, {List<dynamic> args}) async {
    var result = await db.rawQuery(query, args);
    return result;
  }

  Future close() async => db.close();


  Future dropDatabase() async {
    await this.close();
    await deleteDatabase(path);
  }
}
