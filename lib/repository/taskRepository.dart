import 'dart:async';

import 'package:techviz/model/task.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/localRepository.dart';

abstract class ITaskRepository implements IRepository<dynamic>{
  Future<List<Task>> getTaskList();
}

class TaskRepository implements ITaskRepository{

  /**
   * fetch local task list
   */

  @override
  Future<List<Task>> getTaskList() async {
    LocalRepository localRepo = LocalRepository();
    await localRepo.open();

    List<Map<String, dynamic>> queryResult = await localRepo.rawQuery('SELECT * FROM Task');

    List<Task> list = List<Task>();
    queryResult.forEach((Map<String, dynamic> task) {
      double amount = task['Amount'] == '' ? 0.0: (task['Amount'] as double);

      var t = Task(
        id: task['_ID'] as String,
        location: task['Location'] as String,
        taskTypeID: task['TaskTypeID'] as int,
        taskStatusID: task['TaskStatusID'] as int,
        amount: amount,
        eventDesc: task['EventDesc'] as String,
      );
      list.add(t);
    });

    await localRepo.close();

    return list;
  }

  @override
  Future<List<dynamic>> fetch() {
    throw new UnimplementedError('Needs to be overwritten');
  }


}