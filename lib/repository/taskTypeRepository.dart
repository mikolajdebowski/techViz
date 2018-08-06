import 'dart:async';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/localRepository.dart';

abstract class ITaskTypeRepository implements IRepository<dynamic>{
  Future<List<TaskType>> getAll();
}

class TaskTypeRepository implements ITaskTypeRepository{

  /**
   * fetch local
   */
  @override
  Future<List<TaskType>> getAll() async {
    LocalRepository localRepo = LocalRepository();

    List<Map<String, dynamic>> queryResult = await localRepo.rawQuery('SELECT * FROM TaskType');

    List<TaskType> toReturn = List<TaskType>();
    queryResult.forEach((Map<String, dynamic> task) {
      var t = TaskType(
        id: task['TaskTypeID'] as int,
        description: task['TaskTypeDescription'] as String,
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