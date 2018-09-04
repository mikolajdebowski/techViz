import 'dart:async';
import 'package:techviz/model/taskStatus.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/localRepository.dart';
import 'package:techviz/repository/remoteRepository.dart';

class TaskStatusRepository implements IRepository<TaskStatus>{
  IRemoteRepository remoteRepository;
  TaskStatusRepository({this.remoteRepository});

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

  @override
  Future fetch() {
    assert(this.remoteRepository!=null);
    return this.remoteRepository.fetch();
  }

  @override
  Future listen() {
    // TODO: implement listen
  }

  @override
  Future submit(TaskStatus object) {
    // TODO: implement submit
  }


}