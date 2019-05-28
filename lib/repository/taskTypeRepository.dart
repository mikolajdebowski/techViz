import 'dart:async';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/remoteRepository.dart';


class TaskTypeRepository implements IRepository<TaskType>{
  IRemoteRepository remoteRepository;
  TaskTypeRepository({this.remoteRepository});

  Future<List<TaskType>> getAll({TaskTypeLookup lookup}) async {
    LocalRepository localRepo = LocalRepository();

    String query = "SELECT * FROM TaskType";
    if(lookup!=null) {
      String taskTypeLookup = lookup.toString().replaceAll("TaskTypeLookup.", ""); //only  enum value
      query += " WHERE LookupName = '$taskTypeLookup'";
    }

    List<Map<String, dynamic>> queryResult = await localRepo.db.rawQuery(query);

    List<TaskType> toReturn = <TaskType>[];
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
    assert(remoteRepository!=null);
    return remoteRepository.fetch();
  }
}

enum TaskTypeLookup{
  escalationType,
  taskType,
  workType
}