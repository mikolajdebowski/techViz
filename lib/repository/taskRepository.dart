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

  Future insertOrUpdate(Map map){
    return TaskTable(localRepository).insertOrUpdate([map]);
  }

  Future update(String taskID, {String taskStatusID, String cancellationReason, TaskUpdateCallBack callBack} ) async {
    List<int> openTasksIDs = [1,2,3,31,32,33];

    List<dynamic> taskStatusCheck = await LocalRepository().db.rawQuery("SELECT TASKSTATUSID FROM TASK WHERE _ID = '$taskID';");
    if(taskStatusCheck.isEmpty || openTasksIDs.contains(taskStatusCheck.first['TASKSTATUSID']) == false){
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

      if(callBack!=null)
        callBack(taskID);

      _completer.complete(d);
    });

    return _completer.future;
  }

  Future escalateTask(String taskID, EscalationPath escalationPath, {TaskType escalationTaskType, String notes}) async {
    List<int> openTasksIDs = [3,33];
    Completer<dynamic> _completer = Completer<dynamic>();

    List<dynamic> taskStatusCheck = await LocalRepository().db.rawQuery("SELECT TASKSTATUSID FROM TASK WHERE _ID = '$taskID';");
    if(taskStatusCheck.isEmpty || openTasksIDs.contains(taskStatusCheck.first['TASKSTATUSID']) == false){
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