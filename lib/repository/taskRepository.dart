import 'dart:async';
import 'package:techviz/model/task.dart';
import 'package:techviz/model/taskStatus.dart';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/local/taskTable.dart';
//import 'package:techviz/repository/async/taskMessage.dart';
import 'package:techviz/repository/remoteRepository.dart';

typedef TaskUpdateCallBack = void Function(String taskID);
typedef TaskSubmitallBack = void Function(String taskID);

class TaskRepository implements IRepository<Task>{
  IRemoteRepository remoteRepository;
  TaskRepository({this.remoteRepository});

  Future<List<Task>> getTaskList(String userID) async {
    LocalRepository localRepo = LocalRepository();
    if(!localRepo.db.isOpen)
      await localRepo.open();

    String sql = "SELECT "
        "t.*"
        ", ts.TaskStatusDescription "
        ", tt.TaskTypeDescription "
        "FROM TASK t INNER JOIN TaskStatus ts on t.TASKSTATUSID == ts.TaskStatusID INNER JOIN TaskType tt on t.TASKTYPEID == tt.TaskTypeID and t.TASKSTATUSID in (1,2,3) AND t.USERID = '${userID}' ORDER BY t.TASKCREATED ASC;";

    List<Map<String, dynamic>> queryResult = await localRepo.db.rawQuery(sql);

    List<Task> list = List<Task>();
    queryResult.forEach((Map<String, dynamic> task) {
      list.add(_fromMap(task));
    });

    print("list  ${list.length}");

    return list;
  }

  Future<Task> getTask(String taskID) async {
    LocalRepository localRepo = LocalRepository();
    if(!localRepo.db.isOpen)
      await localRepo.open();

    String sql = "SELECT "
        "t.* "
        ",ts.TaskStatusDescription "
        ",tt.TaskTypeDescription "
        "FROM TASK t INNER JOIN TaskStatus ts on t.TASKSTATUSID == ts.TaskStatusID INNER JOIN TaskType tt on t.TASKTYPEID == tt.TaskTypeID WHERE t._ID == '${taskID}';";

    List<Map<String, dynamic>> queryResult = await LocalRepository().db.rawQuery(sql);

    //print("query length => ${queryResult.length}");

    //print("getTask: ${queryResult}");

    return Future.value(queryResult.length>0? _fromMap(queryResult.first): null);
  }

  Task _fromMap(Map<String, dynamic> task){
    var t = Task(
        dirty: task['_Dirty'] == 1,
        version: task['_VERSION'] as int,
        userID: task['USERID'] as String,
        id: task['_ID'] as String,
        location: task['LOCATION'] as String,
        amount: task['AMOUNT'] as double,
        eventDesc: task['EVENTDESC'] as String,
        taskCreated: DateTime.parse(task['TASKCREATED'] as String),
        playerID: task['PLAYERID']!=null ? task['PlayerID'] as String : '',
        playerFirstName: task['PLAYERFIRSTNAME']!=null ? task['PLAYERFIRSTNAME'] as String : '',
        playerLastName: task['PLAYERLASTNAME']!=null ? task['PLAYERLASTNAME'] as String : '',
        playerTier: task['PLAYERTIER']!=null ? task['PlayerTier'] as String : null,
        playerTierColorHEX: task['PLAYERTIERCOLORHEX']!=null ? task['PLAYERTIERCOLORHEX'] as String : null,
        taskType: TaskType(id: task['TASKTYPEID'] as int, description: task['TaskTypeDescription'] as String),
        taskStatus: TaskStatus(id: task['TASKSTATUSID'] as int, description: task['TaskStatusDescription'] as String),
    );

    return t;
  }

  @override
  Future<dynamic> fetch() {
    assert(this.remoteRepository!=null);

    Completer _completer = Completer<bool>();
    this.remoteRepository.fetch().then((Object result) async{

      //await TaskTable.cleanUp();
      await TaskTable.insertOrUpdate(result);

      _completer.complete(true);
    });

    return _completer.future;
  }

  @override
  Future listen() {
    throw UnimplementedError();
  }

  Future update(String taskID, {String taskStatusID, TaskUpdateCallBack callBack, bool markAsDirty = true, bool updateRemote = false} ) async {
    print('updating local...');
    LocalRepository localRepo = LocalRepository();
    if(!localRepo.db.isOpen)
      await localRepo.open();

    int dirty = markAsDirty?1:0;

    if(taskStatusID!=null){
      await  LocalRepository().db.rawUpdate('UPDATE TASK SET _DIRTY = ?, TASKSTATUSID = ? WHERE _ID = ?', [dirty, taskStatusID, taskID].toList());
    }

    if(updateRemote){
      var toSend = {'taskID': taskID, 'taskStatusID': taskStatusID};
      //TaskMessage taskChannel = TaskMessage();
      //await taskChannel.publishMessage(toSend);

      print('rabbitmq update sent');
    }

    if(callBack!=null){
      callBack(taskID);
    }
  }
}