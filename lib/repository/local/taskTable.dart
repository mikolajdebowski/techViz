import 'dart:async';

import 'package:sqflite/sqflite.dart';

class TaskTable{
  static Future<dynamic> create(Database db) {
    return db.execute('''
              create table Task ( 
                  _Dirty INT NOT NULL,
                  _Version INT NOT NULL,
                  _ID TEXT PRIMARY KEY NOT NULL, 
                  EventID INT,
                  UserID TEXT,
                  MachineID TEXT,
                  TaskStatusID INT NOT NULL,
                  TaskTypeID INT,
                  TaskCreated DATETIME,
                  TaskAssigned DATETIME,
                  TaskNote TEXT,
                  TaskResponded DATETIME,
                  Amount REAL,
                  Location TEXT,
                  EventDesc TEXT,
                  PlayerID TEXT,
                  PlayerFirstName TEXT,
                  PlayerLastName TEXT,
                  PlayerTier TEXT,
                  PlayerTierColorHex TEXT)
              ''');
    }

  static Future<dynamic> insertOrUpdate(Database db, dynamic values) {
    int totalRows = 0;

    values.forEach((Map<String,dynamic> each) async{
      totalRows += await db.insert('Task', each, conflictAlgorithm: ConflictAlgorithm.replace);
    });

    return Future<int>.value(totalRows);
  }

  static Future<int> cleanUp(Database db) {
    return db.delete('Task');
  }

}