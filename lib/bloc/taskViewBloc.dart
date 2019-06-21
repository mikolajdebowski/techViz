import 'dart:core';

import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';
import 'package:techviz/model/task.dart';
import 'package:rxdart/subjects.dart';

class TaskViewBloc {
  static final TaskViewBloc _instance = TaskViewBloc._();
  factory TaskViewBloc() => _instance;
  TaskViewBloc._();

  final BehaviorSubject<List<Task>> _openTasksController = BehaviorSubject<List<Task>>();
  final List<Task> _taskList = [];
  final _lock = Lock();

  Stream<List<Task>> get openTasks => _openTasksController.stream;

  void update(Task task) async{
    await _lock.synchronized(() async {
      int idx = _taskList.indexWhere((Task _task) => task.id == _task.id);
      if(idx<0) _taskList.add(task);
      else _taskList[idx] = task;
      _openTasksController.add(_taskList);
    });
  }

  void dispose(){
    _openTasksController?.close();
  }
}