import 'dart:async';
import 'package:techviz/model/taskUrgency.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/remoteRepository.dart';

class TaskUrgencyRepository implements IRepository<TaskUrgency>{
  IRemoteRepository remoteRepository;
  TaskUrgencyRepository({this.remoteRepository});

  Future<List<TaskUrgency>> getAll() async {
    LocalRepository localRepo = LocalRepository();

    List<Map<String, dynamic>> queryResult = await localRepo.db.rawQuery('SELECT * FROM TaskUrgency');

    List<TaskUrgency> toReturn = List<TaskUrgency>();
    queryResult.forEach((Map<String, dynamic> task) {
      var t = TaskUrgency(
        id: task['ID'] as int,
        description: task['Description'] as String,
        colorHex: task['ColorHex'] as String,
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