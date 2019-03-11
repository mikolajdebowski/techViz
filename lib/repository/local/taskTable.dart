import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:techviz/repository/local/localRepository.dart';

class TaskTable {
  static Future<dynamic> create(Database db) {
    return db.execute('''
              CREATE TABLE TASK ( 
                  _ID TEXT PRIMARY KEY NOT NULL, 
                  _DIRTY INT NOT NULL,
                  _VERSION INT NOT NULL,
                  EVENTID INT,
                  USERID TEXT,
                  MACHINEID TEXT,
                  TASKSTATUSID INT NOT NULL,
                  TASKURGENCYID INT NOT NULL,
                  TASKTYPEID INT,
                  TASKCREATED DATETIME,
                  TASKASSIGNED DATETIME,
                  TASKNOTE TEXT,
                  TASKRESPONDED DATETIME,
                  AMOUNT REAL,
                  LOCATION TEXT,
                  EVENTDESC TEXT,
                  PLAYERID TEXT,
                  PLAYERFIRSTNAME TEXT,
                  PLAYERLASTNAME TEXT,
                  PLAYERTIER TEXT,
                  PLAYERTIERCOLORHEX TEXT)
              ''');
  }

  static Future<int> insertOrUpdate(dynamic toInsert) async {
    var toInsertList = toInsert as List<Map<String, dynamic>>;

    if(toInsertList.length==0)
      return Future.value(0);


    Completer<int> _completer = Completer<int>();

    LocalRepository localRepo = LocalRepository();
    if (!localRepo.db.isOpen)
      await localRepo.open();

    int insertedRows = 0;
    int updatedRows = 0;

    Future.forEach<Map<String, dynamic>>(toInsertList, (Map<String, dynamic> entry) async{
      localRepo.db.transaction((txn) async {
        var batch = txn.batch();

        List<Map<String,dynamic>> exists = await txn.rawQuery("SELECT _ID FROM TASK WHERE _ID = '${entry['_ID'].toString()}';");
        if(exists!=null && exists.length>0){
          print('task ${entry['LOCATION'].toString()} EXISTS! UPDATING WITH STATUSID ${entry['TASKSTATUSID'].toString()}');
          String sqlUpdate = buildUpdateSQL(entry);
          updatedRows = await txn.rawUpdate(sqlUpdate);
        }
        else{
          print('task ${entry['LOCATION'].toString()} DOES NOT exist! INSERTING WITH STATUSID ${entry['TASKSTATUSID'].toString()}');
          insertedRows += await txn.insert('Task', entry, conflictAlgorithm: ConflictAlgorithm.replace);
        }

        await batch.commit();
      });
    }).then((dynamic end){
      _completer.complete(insertedRows+updatedRows);
    });

    return _completer.future;
  }

  static Future<int> invalidateTasks() async
  {
    LocalRepository localRepo = LocalRepository();
    if (!localRepo.db.isOpen)
      await localRepo.open();

    String sqlUpdate = "UPDATE TASK SET TASKSTATUSID = 7 WHERE TASKSTATUSID IN (1,2,3);";
    int updatedRows = await localRepo.db.rawUpdate(sqlUpdate);

    return Future.value(updatedRows);
  }

  static String buildUpdateSQL(Map<String, dynamic> row){
    String sql = "UPDATE TASK SET ";
    row.forEach((String key, dynamic value)
    {
        if(value == null){
          sql += " ${key} = null,";
        }
        else if(value.runtimeType == String || value.runtimeType == DateTime){
          sql += " ${key} = '${value}',";
        }
        else if(value.runtimeType == bool){
          bool bValue = value as bool;
          sql += " ${key} = ${(bValue) ? 1: 0},";
        }
        else {
          sql += " ${key} = ${value},";
        }
    });
    sql = (sql.substring(0, sql.length - 1));
    sql += " WHERE _ID = '${row['_ID']}'; ";

    //print("UPDATING... " + sql);
    return sql;
  }

  static Future<int> cleanUp() async {
    LocalRepository localRepo = LocalRepository();
    if (!localRepo.db.isOpen)
      await localRepo.open();

    int deletedRows = await localRepo.db.delete('Task');

    return Future.value(deletedRows);
  }
}
