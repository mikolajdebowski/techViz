import 'dart:async';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/localRepository.dart';
import 'package:techviz/repository/remoteRepository.dart';


class TaskTypeRepository implements IRepository<TaskType>{
  IRemoteRepository remoteRepository;
  TaskTypeRepository({this.remoteRepository});

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

  @override
  Future fetch() {
    assert(this.remoteRepository!=null);
    return this.remoteRepository.fetch();
  }

  @override
  Future listen() {
    throw UnimplementedError();
  }

  @override
  Future submit(TaskType object) {
    throw UnimplementedError();
  }
}