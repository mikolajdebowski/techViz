import 'dart:async';

import 'package:techviz/model/task.dart';
import 'package:techviz/model/taskStatus.dart';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/localRepository.dart';
import 'package:techviz/repository/remoteRepository.dart';

class TaskRepository implements IRepository<Task>{
  IRemoteRepository remoteRepository;
  TaskRepository({this.remoteRepository});

  Future<List<Task>> getTaskList() async {
    LocalRepository localRepo = LocalRepository();

    String sql = 'SELECT '
        't.Amount, '
        't._ID, '
        't.Location, '
        't.EventDesc, '
        't.TaskCreated, '
        't.PlayerID, '
        't.PlayerFirstName, '
        't.PlayerLastName, '
        't.PlayerTier, '
        't.PlayerTierColorHex, '
        'ts.TaskStatusID, '
        'ts.TaskStatusDescription, '
        'tt.TaskTypeID, '
        'tt.TaskTypeDescription '
        'FROM Task t INNER JOIN TaskStatus ts on t.TaskStatusID == ts.TaskStatusID INNER JOIN TaskType tt on t.TaskTypeID == tt.TaskTypeID;';

    List<Map<String, dynamic>> queryResult = await localRepo.rawQuery(sql);

    List<Task> list = List<Task>();
    queryResult.forEach((Map<String, dynamic> task) {
      double amount = task['Amount'] == '' ? 0.0: (task['Amount'] as double);

      var t = Task(
        id: task['_ID'] as String,
        location: task['Location'] as String,
        taskType: TaskType(id: task['TaskTypeID'] as int, description: task['TaskTypeDescription'] as String),
        taskStatus: TaskStatus(id: task['TaskStatusID'] as int, description: task['TaskStatusDescription'] as String),
        amount: amount,
        eventDesc: task['EventDesc'] as String,
        taskCreated: DateTime.parse(task['TaskCreated'] as String),
        playerID: task['PlayerID']!=null ? task['PlayerID'] as String : '',
        playerFirstName: task['PlayerFirstName']!=null ? task['PlayerFirstName'] as String : '',
        playerLastName: task['PlayerLastName']!=null ? task['PlayerLastName'] as String : '',
        playerTier: task['PlayerTier']!=null ? task['PlayerTier'] as String : null,
        playerTierColorHEX: task['PlayerTierColorHex']!=null ? task['PlayerTierColorHex'] as String : null
      );
      list.add(t);
    });

    return list;
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
  Future submit(Task object) {
    throw UnimplementedError();
  }
}