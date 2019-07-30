import 'package:techviz/model/taskType.dart';
import 'package:techviz/repository/local/localTable.dart';

import '../taskTypeRepository.dart';
import 'localRepository.dart';

abstract class ITaskTypeTable{
  Future<List<TaskType>> getAll({TaskTypeLookup lookup});
  Future<int> insertAll(List<Map<String,dynamic>> list);
}

class TaskTypeTable extends LocalTable implements ITaskTypeTable{
  TaskTypeTable(ILocalRepository localRepo): super(localRepo: localRepo){
    tableName = 'TaskType';
    createSQL = '''
              CREATE TABLE $tableName ( 
                  TaskTypeID INT PRIMARY KEY NOT NULL, 
                  TaskTypeDescription TEXT NOT NULL,
                  LookupName TEXT NOT NULL)
              ''';
  }

  @override
  Future<List<TaskType>> getAll({TaskTypeLookup lookup}) async{
    String query = "SELECT * FROM TaskType";
    if (lookup != null) {
      String taskTypeLookup = lookup.toString().replaceAll("TaskTypeLookup.", ""); //only  enum value
      query += " WHERE LookupName = '$taskTypeLookup'";
    }

    List<Map<String, dynamic>> queryResult = await localRepo.db.rawQuery(query);

    List<TaskType> toReturn = <TaskType>[];
    queryResult.forEach((Map<String, dynamic> task) {
      TaskType t = TaskType(
        taskTypeId: task['TaskTypeID'] as int,
        description: task['TaskTypeDescription'] as String,
        lookupName: task['LookupName'] as String,
      );
      toReturn.add(t);
    });

    return toReturn;
  }

  @override
  Future<int> insertAll(List<Map<String, dynamic>> list){
    int count = 0;
    Future.forEach(list, (Map map) async{
      count += await localRepo.db.insert(tableName, map);
    });
    return Future<int>.value(count);
  }
}