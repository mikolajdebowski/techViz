import 'dart:async';
import 'package:techviz/model/escalationPath.dart';
import 'package:techviz/model/task.dart';
import 'package:techviz/model/taskStatus.dart';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/repository/async/TaskRouting.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/local/taskTable.dart';
import 'package:techviz/repository/remoteRepository.dart';
import 'dart:convert';

typedef TaskUpdateCallBack = void Function(String taskID);
typedef TaskSubmitallBack = void Function(String taskID);

class TaskRepository implements IRepository<Task>{

  IRemoteRepository remoteRepository;
  TaskRepository({this.remoteRepository});

  Future<List<Task>> getOpenTasks(String userID) async {

    LocalRepository localRepo = LocalRepository();
    if(!localRepo.db.isOpen)
      await localRepo.open();

    String sql = "SELECT "
        "t.*"
        ", ts.TaskStatusDescription "
        ", tt.TaskTypeDescription "
        ", tu.ColorHex "
        " FROM TASK t "
        " INNER JOIN TaskStatus ts on t.TASKSTATUSID == ts.TaskStatusID "
        " INNER JOIN TaskType tt on t.TASKTYPEID == tt.TaskTypeID "
        " INNER JOIN TaskUrgency tu on t.TaskUrgencyID == tu.ID "
        " WHERE t.TASKSTATUSID in (1,2,3) AND t.USERID = '${userID}' "
        " ORDER BY t.TASKCREATED ASC;";

    List<Map<String, dynamic>> queryResult = await localRepo.db.rawQuery(sql);

    List<Task> list = List<Task>();
    queryResult.forEach((Map<String, dynamic> task) {
      list.add(_fromMap(task));
    });

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
        ",tt.LookupName as TaskTypeLookupName "
        "FROM TASK t INNER JOIN TaskStatus ts on t.TASKSTATUSID == ts.TaskStatusID INNER JOIN TaskType tt on t.TASKTYPEID == tt.TaskTypeID WHERE t._ID == '${taskID}';";

    List<Map<String, dynamic>> queryResult = await LocalRepository().db.rawQuery(sql);

    return Future.value(queryResult.length>0? _fromMap(queryResult.first): null);
  }

  Task _fromMap(Map<String, dynamic> task){
    var t = Task(
        dirty: task['_DIRTY'] == 1,
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
        taskType: TaskType(taskTypeId: task['TASKTYPEID'] as int, description: task['TaskTypeDescription'].toString(), lookupName: task['TaskTypeLookupName'].toString()),
        taskStatus: TaskStatus(id: task['TASKSTATUSID'] as int, description: task['TaskStatusDescription'] as String),
        urgencyHEXColor: task['ColorHex'] as String
    );

    return t;
  }

  @override
  Future<dynamic> fetch() {
    assert(this.remoteRepository!=null);

    Completer _completer = Completer<bool>();
    this.remoteRepository.fetch().then((Object result) async{
      await TaskTable.cleanUp();
      await TaskTable.insertOrUpdate(result);
      _completer.complete(true);
    });

    return _completer.future;
  }

  StreamController listenQueue(Function onData, Function onError)  {

    return TaskRouting().ListenQueue((dynamic receivedTask) async{

      dynamic task = jsonDecode(receivedTask.toString());

      Map<String,dynamic> taskMapped = Map<String,dynamic>();
      taskMapped['_ID'] = task['_ID'];
      taskMapped['_DIRTY'] = false;
      taskMapped['_VERSION'] =  task['_version'];
      taskMapped['USERID'] = task['userID'];
      taskMapped['LOCATION'] = task['location'];
      taskMapped['TASKSTATUSID'] = task['taskStatusID'];
      taskMapped['TASKTYPEID'] = task['taskTypeID'];
      taskMapped['MACHINEID'] = task['machineID'];
      taskMapped['TASKURGENCYID'] = task['taskUrgencyID'];

      taskMapped['TASKCREATED'] = task['taskCreated'];
      taskMapped['TASKASSIGNED'] = task['taskAssigned'];
      taskMapped['PLAYERID'] = task['playerID'];
      taskMapped['AMOUNT'] = task['amount'] == null ||  task['amount'] =='' ? 0.0 : task['amount'];

      taskMapped['EVENTDESC'] = task['eventDesc'];
      taskMapped['PLAYERFIRSTNAME'] = task['firstName'];
      taskMapped['PLAYERLASTNAME'] = task['lastName'];
      taskMapped['PLAYERTIER'] = task['tier'];
      taskMapped['PLAYERTIERCOLORHEX'] = task['tierColorHex'];


      await TaskTable.insertOrUpdate([taskMapped]);

      Task taskUpdate = await TaskRepository().getTask(task['_ID'].toString());
      onData(taskUpdate);

    }, onError: onError, onCancel: (){
      print('onCancel called');
    });
  }

  Future update(String taskID, {String taskStatusID, String cancellationReason, TaskUpdateCallBack callBack} ) async {
    LocalRepository localRepo = LocalRepository();
    if(!localRepo.db.isOpen)
      await localRepo.open();

    List<dynamic> taskStatusCheck = await LocalRepository().db.rawQuery("SELECT TASKSTATUSID FROM TASK WHERE _ID = '$taskID';");
    if(taskStatusCheck.isEmpty || [1,2,3].contains(taskStatusCheck.first['TASKSTATUSID']) == false){
      throw TaskNotAvailableException();
    }

    Completer<dynamic> _completer = Completer<dynamic>();

    dynamic message;
    if(taskStatusID=='12'){
      message = {'taskID': taskID, 'taskStatusID': taskStatusID, 'tasknote': base64.encode(utf8.encode(cancellationReason))};
    }
    else{
      message = {'taskID': taskID, 'taskStatusID': taskStatusID};
    }

    TaskRouting().PublishMessage(message).then((dynamic d) async{

      LocalRepository localRepo = LocalRepository();
      if(!localRepo.db.isOpen)
        await localRepo.open();

      await  LocalRepository().db.rawUpdate('UPDATE TASK SET _DIRTY = 1 WHERE _ID = ?', [taskID].toList());

      callBack(taskID);
      _completer.complete(d);
    });

    return _completer.future;
  }

  Future escalateTask(String taskID, EscalationPath escalationPath, {TaskType escalationTaskType, String notes}) async {
    Completer<dynamic> _completer = Completer<dynamic>();


    LocalRepository localRepo = LocalRepository();
    if(!localRepo.db.isOpen)
      await localRepo.open();

    List<dynamic> taskStatusCheck = await LocalRepository().db.rawQuery("SELECT TASKSTATUSID FROM TASK WHERE _ID = '$taskID';");
    if(taskStatusCheck.isEmpty || taskStatusCheck.first['TASKSTATUSID'] != 3){
      throw TaskNotAvailableException();
    }

    dynamic message = {'taskID': taskID, 'TaskStatusID': '5', 'EscalationPath': escalationPath.id};
    if(escalationTaskType!=null){
      message['EscalationTypeID'] = escalationTaskType.taskTypeId;
    }
    if(notes!=null && notes.isNotEmpty){
      message['tasknote'] = base64.encode(utf8.encode(notes));
    }

    TaskRouting().PublishMessage(message).then((dynamic d) async{

      //ONLY UPDATE LOCALLY AFTER CALLBACK RETURNS
      LocalRepository localRepo = LocalRepository();
      if(!localRepo.db.isOpen)
        await localRepo.open();

      await  LocalRepository().db.rawUpdate('UPDATE TASK SET _DIRTY = 1 WHERE _ID = ?', [taskID].toList());

      _completer.complete(d);
    }).catchError((dynamic error){
      _completer.completeError(error);
    });

    return _completer.future;
  }
}

class TaskNotAvailableException implements Exception{
  String cause = 'This task is not available anymore';
  TaskNotAvailableException();

  @override
  String toString() {
    return cause.toString();
  }
}