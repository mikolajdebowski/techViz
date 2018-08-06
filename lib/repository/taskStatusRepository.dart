import 'dart:async';
import 'package:techviz/model/taskStatus.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/localRepository.dart';

abstract class ITaskStatusRepository implements IRepository<dynamic>{
  Future<List<TaskStatus>> getAll();
}

class TaskStatusRepository implements ITaskStatusRepository{

  /**
   * fetch local
   */
  @override
  Future<List<TaskStatus>> getAll() async {
    LocalRepository localRepo = LocalRepository();

    List<Map<String, dynamic>> queryResult = await localRepo.rawQuery('SELECT * FROM TaskStatus');

    List<TaskStatus> toReturn = List<TaskStatus>();
    queryResult.forEach((Map<String, dynamic> task) {
      var t = TaskStatus(
        id: task['TaskStatusID'] as int,
        description: task['TaskStatusDescription'] as String,
      );
      toReturn.add(t);
    });

    return toReturn;
  }

  /**
   * fetch remote
   */
  @override
  Future<List<dynamic>> fetch() {
    throw new UnimplementedError('Needs to be overwritten');
  }
}