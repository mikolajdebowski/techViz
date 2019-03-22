import 'dart:async';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/remoteRepository.dart';


class TaskTypeRepository implements IRepository<TaskType>{
  IRemoteRepository remoteRepository;
  TaskTypeRepository({this.remoteRepository});

  Future<List<TaskType>> getAll(TaskTypeLookup lookup) async {
    LocalRepository localRepo = LocalRepository();

    String taskTypeLookup = lookup.toString().split('.')[1]; //only  enum value

    List<Map<String, dynamic>> queryResult = await localRepo.db.rawQuery("SELECT * FROM TaskType WHERE LookupName = '$taskTypeLookup'");

    List<TaskType> toReturn = List<TaskType>();
    queryResult.forEach((Map<String, dynamic> task) {
      var t = TaskType(
        taskTypeId: task['TaskTypeID'] as int,
        description: task['TaskTypeDescription'] as String,
        lookupName: task['LookupName'] as String,
      );
      toReturn.add(t);
    });

    return toReturn;
  }

  @override
  Future fetch() {
    assert(this.remoteRepository!=null);
    return this.remoteRepository.fetch();
  }
}

enum TaskTypeLookup{
  escalationType,
  taskType,
  workType
}