import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:techviz/model/task.dart';
import 'package:techviz/model/taskStatus.dart';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'localTable.dart';

abstract class ITaskTable {
  Future<int> insertOrUpdate(dynamic toInsert);
  Future<int> invalidateTasks();
  Future<int> cleanUp();
  Future<Task> getTask(String taskID);
}

class TaskTable extends LocalTable implements ITaskTable{

  TaskTable(ILocalRepository localRepo): super(localRepo: localRepo){
    createSQL = '''
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
                  PLAYERTIERCOLORHEX TEXT,
                  ISTECHTASK INT)
              ''';
  }

  @override
  Future<int> insertOrUpdate(dynamic toInsert) async {
    List<Map<dynamic, dynamic>> toInsertList = toInsert as List<Map<dynamic, dynamic>>;

    if(toInsertList.isEmpty)
      return Future.value(0);

    Completer<int> _completer = Completer<int>();

    int insertedRows = 0;
    int updatedRows = 0;

    Future.forEach<Map<dynamic, dynamic>>(toInsertList, (Map<dynamic, dynamic> entry) async{
      localRepo.db.transaction((txn) async {
        Batch batch = txn.batch();

        List<Map<String,dynamic>> exists = await txn.rawQuery("SELECT _ID FROM TASK WHERE _ID = '${entry['_ID'].toString()}';");
        if(exists!=null && exists.isNotEmpty){
          //print('task ${entry['LOCATION'].toString()} EXISTS! UPDATING WITH STATUSID ${entry['TASKSTATUSID'].toString()}');
          String sqlUpdate = _buildUpdateSQL(entry);
          updatedRows = await txn.rawUpdate(sqlUpdate);
        }
        else{
          //print('task ${entry['LOCATION'].toString()} DOES NOT exist! INSERTING WITH STATUSID ${entry['TASKSTATUSID'].toString()}');
          insertedRows += await txn.insert('Task', entry, conflictAlgorithm: ConflictAlgorithm.replace);
        }

        await batch.commit();
      });
    }).then((dynamic end){
      _completer.complete(insertedRows+updatedRows);
    });

    return _completer.future;
  }

  @deprecated
  @override
  Future<int> invalidateTasks() async
  {
    String sqlUpdate = "UPDATE TASK SET TASKSTATUSID = 7 WHERE TASKSTATUSID IN (1,2,3);";
    int updatedRows = await localRepo.db.rawUpdate(sqlUpdate);
    return Future.value(updatedRows);
  }

  String _buildUpdateSQL(Map<String, dynamic> row){
    String sql = "UPDATE TASK SET ";
    row.forEach((String key, dynamic value)
    {
        if(value == null || (value is String && value == 'null')){
          sql += " $key = null,";
        }
        else if(value.runtimeType == String || value.runtimeType == DateTime){
          sql += " $key = '$value',";
        }
        else if(value.runtimeType == bool){
          bool bValue = value as bool;
          sql += " $key = ${bValue ? 1: 0},";
        }
        else {
          sql += " $key = $value,";
        }
    });
    sql = sql.substring(0, sql.length - 1);
    sql += " WHERE _ID = '${row['_ID']}'; ";

    //print("UPDATING... " + sql);
    return sql;
  }

  @override
  Future<int> cleanUp() async {
    int deletedRows = await localRepo.db.delete('Task');
    return Future.value(deletedRows);
  }

  @override
  Future<Task> getTask(String taskID) async {
    String sql = "SELECT "
        "t.* "
        ",ts.TaskStatusDescription "
        ",tt.TaskTypeDescription "
        ",tt.LookupName as TaskTypeLookupName "
        ",tu.ColorHex "
        "FROM TASK t "
        "INNER JOIN TaskStatus ts on t.TASKSTATUSID == ts.TaskStatusID "
        "INNER JOIN TaskType tt on t.TASKTYPEID == tt.TaskTypeID "
        "INNER JOIN TaskUrgency tu on t.TaskUrgencyID == tu.ID "
        "WHERE t._ID == '$taskID';";

    List<Map<String, dynamic>> queryResult = await LocalRepository().db.rawQuery(sql);
    return Future.value(queryResult.isNotEmpty? _fromMap(queryResult.first): null);
  }

  Task _fromMap(Map<String, dynamic> task){

    return Task(
        dirty: task['_DIRTY'] as int,
        version: task['_VERSION'] as int,
        userID: task['USERID'] as String,
        id: task['_ID'] as String,
        location: task['LOCATION'] as String,
        amount: task['AMOUNT'] as double,
        eventDesc: task['EVENTDESC'] as String,
        taskCreated: DateTime.parse(task['TASKCREATED'] as String),
        playerID: task['PLAYERID']!=null ? task['PLAYERID'] as String : '',
        playerFirstName: task['PLAYERFIRSTNAME']!=null ? task['PLAYERFIRSTNAME'] as String : '',
        playerLastName: task['PLAYERLASTNAME']!=null ? task['PLAYERLASTNAME'] as String : '',
        playerTier: task['PLAYERTIER']!=null ? task['PLAYERTIER'] as String : null,
        playerTierColorHEX: task['PLAYERTIERCOLORHEX']!=null ? task['PLAYERTIERCOLORHEX'] as String : null,
        taskType: TaskType(task['TASKTYPEID'] as int, task['TaskTypeDescription'].toString(), task['TaskTypeLookupName'].toString()),
        taskStatus: TaskStatus(id: task['TASKSTATUSID'] as int, description: task['TaskStatusDescription'] as String),
        urgencyHEXColor: task['ColorHex'] as String,
        isTechTask: task['ISTECHTASK'] as int == 1
    );

  }
}
