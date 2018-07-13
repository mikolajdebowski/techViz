import 'dart:async';

import 'package:techviz/model/task.dart';
import 'package:techviz/repository/common/IRepository.dart';

abstract class ITaskRepository implements IRepository<dynamic>{
  Future<List<Task>> getTaskList();
}