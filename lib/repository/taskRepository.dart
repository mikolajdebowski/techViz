import 'dart:async';
import 'package:techviz/model/task.dart';
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
  TaskRepository(this.remoteRepository, this.localRepository);

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
}