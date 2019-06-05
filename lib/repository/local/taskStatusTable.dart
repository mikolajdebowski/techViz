import 'package:techviz/model/taskStatus.dart';
import 'package:techviz/repository/local/localTable.dart';

import 'localRepository.dart';

abstract class ITaskStatusTable{
  Future<List<TaskStatus>> getAll();
  Future<int> insertAll(List<Map<String,dynamic>> list);
}

class TaskStatusTable extends LocalTable implements ITaskStatusTable{
  TaskStatusTable(ILocalRepository localRepo): super(localRepo: localRepo){
    tableName = 'TaskStatus';
    createSQL = '''
            create table $tableName ( 
                TaskStatusID INT PRIMARY KEY,
                TaskStatusDescription TEXT NOT NULL
                )
            ''';
  }

  @override
  Future<List<TaskStatus>> getAll() async{
    List<Map<String, dynamic>> queryResult = await localRepo.db.rawQuery('SELECT * FROM TaskStatus');
    List<TaskStatus> toReturn = <TaskStatus>[];
    queryResult.forEach((Map<String, dynamic> task) {
      TaskStatus t = TaskStatus(
        id: task['TaskStatusID'] as int,
        description: task['TaskStatusDescription'] as String,
      );
      toReturn.add(t);
    });
    return toReturn;
  }

  @override
  Future<int> insertAll(List<Map<String, dynamic>> list) {
    int count = 0;
    Future.forEach(list, (Map map) async{
      count += await localRepo.db.insert(tableName, map);
    });
    return Future<int>.value(count);
  }
}
