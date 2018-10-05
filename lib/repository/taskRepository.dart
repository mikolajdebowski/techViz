import 'dart:async';
import 'package:techviz/model/task.dart';
import 'package:techviz/model/taskStatus.dart';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/local/taskTable.dart';
import 'package:techviz/repository/rabbitmq/channel/taskChannel.dart';
import 'package:techviz/repository/remoteRepository.dart';

typedef TaskUpdateCallBack = void Function(String taskID);
typedef TaskSubmitallBack = void Function(String taskID);

class TaskRepository implements IRepository<Task>{
  IRemoteRepository remoteRepository;
  TaskRepository({this.remoteRepository});

  Future<List<Task>> getTaskList(String userID) async {
    LocalRepository localRepo = LocalRepository();
    await localRepo.open();

    String sql = "SELECT "
        "t.*"
        ", ts.TaskStatusDescription "
        ", tt.TaskTypeDescription "
        "FROM Task t INNER JOIN TaskStatus ts on t.TaskStatusID == ts.TaskStatusID INNER JOIN TaskType tt on t.TaskTypeID == tt.TaskTypeID and t.TaskStatusID in (1,2,3) AND t.UserID = '${userID}' ORDER BY t.TaskCreated ASC;";

    List<Map<String, dynamic>> queryResult = await localRepo.db.rawQuery(sql);

    List<Task> list = List<Task>();
    queryResult.forEach((Map<String, dynamic> task) {
      list.add(_parse(task));
    });

    return list;
  }

  Future<Task> getTask(String taskID) async {
    LocalRepository localRepo = LocalRepository();
    await localRepo.open();

    String sql = "SELECT "
        "t.* "
        ",ts.TaskStatusDescription "
        ",tt.TaskTypeDescription "
        "FROM Task t INNER JOIN TaskStatus ts on t.TaskStatusID == ts.TaskStatusID INNER JOIN TaskType tt on t.TaskTypeID == tt.TaskTypeID AND t._ID == '${taskID}';";

    List<Map<String, dynamic>> queryResult = await localRepo.db.rawQuery(sql);

    return _parse(queryResult.first);
  }

  Task _parse(Map<String, dynamic> task){
    var t = Task(
        dirty: task['_Dirty'] == 1,
        version: task['_Version'] as int,
        userID: task['UserID'] as String,
        id: task['_ID'] as String,
        location: task['Location'] as String,
        amount: task['Amount'] as double,
        eventDesc: task['EventDesc'] as String,
        taskCreated: DateTime.parse(task['TaskCreated'] as String),
        playerID: task['PlayerID']!=null ? task['PlayerID'] as String : '',
        playerFirstName: task['PlayerFirstName']!=null ? task['PlayerFirstName'] as String : '',
        playerLastName: task['PlayerLastName']!=null ? task['PlayerLastName'] as String : '',
        playerTier: task['PlayerTier']!=null ? task['PlayerTier'] as String : null,
        playerTierColorHEX: task['PlayerTierColorHex']!=null ? task['PlayerTierColorHex'] as String : null,
        taskType: TaskType(id: task['TaskTypeID'] as int, description: task['TaskTypeDescription'] as String),
        taskStatus: TaskStatus(id: task['TaskStatusID'] as int, description: task['TaskStatusDescription'] as String),
    );

    return t;
  }

  @override
  Future<dynamic> fetch() {
    assert(this.remoteRepository!=null);

    Completer _completer = Completer<bool>();
    this.remoteRepository.fetch().then((Object result) async{
      LocalRepository localRepo = LocalRepository();
      localRepo.open();

      await TaskTable.cleanUp(localRepo.db);
      await TaskTable.insertOrUpdate(localRepo.db, result);

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
    await localRepo.open();

    int dirty = markAsDirty?1:0;

    if(taskStatusID!=null){
      await localRepo.db.rawUpdate('UPDATE Task SET _Dirty = ?, TaskStatusID = ? WHERE _ID = ?', [dirty, taskStatusID, taskID].toList());
    }
    await localRepo.db.close();

    if(updateRemote){
      var toSend = {'taskID': taskID, 'taskStatusID': taskStatusID};
      TaskChannel taskChannel = TaskChannel();
      await taskChannel.submit(toSend);

      print('rabbitmq update sent');
    }

    if(callBack!=null){
      callBack(taskID);
    }
  }
}