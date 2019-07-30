import 'dart:async';
import 'package:techviz/model/taskStatus.dart';

import 'local/taskStatusTable.dart';

abstract class ITaskStatusRemoteRepository{
  Future fetch();
}

class TaskStatusRepository{
  ITaskStatusRemoteRepository remoteRepository;
  ITaskStatusTable taskStatusTable;
  TaskStatusRepository(this.remoteRepository, this.taskStatusTable);

  Future fetch() async {
    assert(remoteRepository!=null);
    dynamic data = await remoteRepository.fetch();
    return taskStatusTable.insertAll(data);
  }

  Future<List<TaskStatus>> getAll() async {
    return taskStatusTable.getAll();
  }
}