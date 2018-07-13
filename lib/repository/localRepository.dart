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
            create table TASK ( 
                ID text primary key, 
                Location text not null)
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

    deleteDatabase(path);
  }
}
