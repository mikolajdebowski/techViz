import 'dart:core';

import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';
import 'package:techviz/model/task.dart';
import 'package:rxdart/subjects.dart';

import '../session.dart';
import 'IViewBloc.dart';

class TaskViewBloc implements IViewBloc{

  List<int> openTasksIDs = [1,2,3,31,32,33];

  static final TaskViewBloc _instance = TaskViewBloc._();
  factory TaskViewBloc() => _instance;
  TaskViewBloc._();

  final BehaviorSubject<List<Task>> _openTasksController = BehaviorSubject<List<Task>>();
  final List<Task> _taskList = [];
  final _lock = Lock();

  Stream<List<Task>> get openTasks => _openTasksController.stream;

  @override
  void dispose(){
    _taskList.clear();
  }

  void update(Task task) async{
    await _lock.synchronized(() async {
      if(task.dirty == 0){
        _handleRemoteTask(task);
      }
      else {
        _handleLocalTask(task);
      }
    });
  }

  void _handleLocalTask(Task task){
    print('STREAM: updating ${task.location} status ${task.taskStatus.id} dirty ${task.dirty}');
    int idx = _taskList.indexWhere((Task _task) => task.id == _task.id);
    if(idx>=0){
      _taskList[idx] = task;
      _openTasksController.add(_taskList);
    }
  }

  //DATA BEING PUSHED BY SERVICE => FRESH DATA FROM THE SERVER
  void _handleRemoteTask(Task task){
    String userID = Session().user.userID;

    int idx = _taskList.indexWhere((Task _task) => task.id == _task.id);
    if(openTasksIDs.contains(task.taskStatus.id) && userID == task.userID){
      if(idx<0){
        print('STREAM: adding ${task.location} status ${task.taskStatus.id} userid ${task.userID}');
        _taskList.add(task);
      }
      else{
        print('STREAM: updating ${task.location} status ${task.taskStatus.id} userid ${task.userID}');
        _taskList[idx] = task;
      }
    }
    else if(idx>=0){
      print('STREAM: removing ${task.location} status ${task.taskStatus.id} userid ${task.userID}');
      _taskList.removeAt(idx);
    }
    else{
      print('STREAM: ?????? ${task.location} status ${task.taskStatus.id} userid ${task.userID}');
    }
    _openTasksController.add(_taskList);
  }
}