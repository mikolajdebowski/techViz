import 'dart:async';
import 'package:techviz/model/taskType.dart';
import 'local/taskTypeTable.dart';

abstract class ITaskTypeRemoteRepository{
  Future fetch();
}

class TaskTypeRepository {
  ITaskTypeRemoteRepository remoteRepository;
  ITaskTypeTable taskTypeTable;
  TaskTypeRepository(this.remoteRepository, this.taskTypeTable);

  Future fetch() async {
    assert(remoteRepository!=null);
    dynamic data = await remoteRepository.fetch();
    return taskTypeTable.insertAll(data);
  }

  Future<List<TaskType>> getAll({TaskTypeLookup lookup}) async {
    return taskTypeTable.getAll(lookup: lookup);
  }
}

enum TaskTypeLookup{
  escalationType,
  taskType,
  workType
}