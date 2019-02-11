
import 'package:sqflite/sqflite.dart';

class TaskUrgencyTable {
  static Future<void> create(Database db) {
    return db.execute('''
              CREATE TABLE TaskUrgency ( 
                  ID INT PRIMARY KEY NOT NULL, 
                  Description TEXT NOT NULL,
                  ColorHex TEXT NOT NULL)
              ''');
  }
}
