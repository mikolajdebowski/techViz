import 'dart:async';
import 'dart:convert';
import 'package:techviz/model/escalationPath.dart';
import 'package:techviz/model/task.dart';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/repository/async/TaskRouting.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/local/taskTable.dart';

typedef TaskUpdateCallBack = void Function(String taskID);
typedef TaskSubmitallBack = void Function(String taskID);

abstract class ITaskRemoteRepository {
  Future fetch();
  Future openTasksSummary();
}

class TaskRepository{

  ITaskRemoteRepository remoteRepository;
  ILocalRepository localRepository;
  TaskRouting taskRouting;
  TaskRepository(this.remoteRepository, this.localRepository, this.taskRouting);


  Future<List<Task>> getOpenTasks(String userID) async {
    return TaskTable(localRepository).getOpenTasks(userID);
  }

  Future<Task> getTask(String taskID) async {
    return TaskTable(localRepository).getTask(taskID);
  }

  //REMOTE FETCH
  Future<dynamic> fetch() {
    assert(remoteRepository!=null);

    Completer _completer = Completer<bool>();
    remoteRepository.fetch().then((Object result) async{
      await TaskTable(localRepository).cleanUp();
      await TaskTable(localRepository).insertOrUpdate(result);
      _completer.complete(true);
    });

    return _completer.future;
  }

  Future openTasksSummary() async {
    return remoteRepository.openTasksSummary();
  }

  StreamController listenQueue(Function onData, Function onError)  {
    return taskRouting.ListenQueue((dynamic receivedTask) async{
      dynamic task = jsonDecode(receivedTask.toString());

      Map<String,dynamic> taskMapped = <String,dynamic>{};
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

      await TaskTable(localRepository).insertOrUpdate([taskMapped]);
      Task taskUpdate = await TaskTable(localRepository).getTask(task['_ID'].toString());
      onData(taskUpdate);

    }, onError: onError, onCancel: (){
      print('onCancel called');
    });
  }

  Future update(String taskID, {String taskStatusID, String cancellationReason, TaskUpdateCallBack callBack} ) async {
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

    taskRouting.PublishMessage(message).then((dynamic d) async{
      await localRepository.db.rawUpdate('UPDATE TASK SET _DIRTY = 1 WHERE _ID = ?', [taskID].toList());

      callBack(taskID);
      _completer.complete(d);
    });

    return _completer.future;
  }

  Future escalateTask(String taskID, EscalationPath escalationPath, {TaskType escalationTaskType, String notes}) async {
    Completer<dynamic> _completer = Completer<dynamic>();

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

    taskRouting.PublishMessage(message).then((dynamic d) async{
      await localRepository.db.rawUpdate('UPDATE TASK SET _DIRTY = 1 WHERE _ID = ?', [taskID].toList());
      _completer.complete(d);
    }).catchError((dynamic error){
      _completer.completeError(error);
    });

    return _completer.future;
  }

  Future reassign(String taskID, String userID) async {
    Completer<dynamic> _completer = Completer<dynamic>();
    dynamic message = {'taskID': taskID, 'userID': userID};

    taskRouting.PublishMessage(message).then((dynamic d) async{
      await localRepository.db.rawUpdate('UPDATE TASK SET _DIRTY = 1 WHERE _ID = ?', [taskID].toList());
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