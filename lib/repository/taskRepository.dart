import 'dart:async';
import 'package:techviz/model/task.dart';
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