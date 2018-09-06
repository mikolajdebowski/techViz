//import 'dart:async';
//
//import 'package:techviz/model/task.dart';
//import 'package:techviz/repository/taskRepository.dart';
//
//class MockTaskRepository extends TaskRepository{
//
//  @override
//  Future<List<dynamic>> fetch() {
//    return Future.value();
//  }
//
//  @override
//  Future<List<Task>> getTaskList() {
//    return Future.value(kTask);
//  }
//}
//
//const kTask = const <Task>[
//  const Task(
//    id: '1',
//    location:'01-01-01',
//    taskTypeID: 1,
//    taskStatusID: 1,
//  ),
//  const Task(
//    id: '2',
//    location: '01-01-02',
//    taskTypeID: 1,
//    taskStatusID: 1,
//  ),
//  const Task(
//    id:  '3',
//    location:'01-01-03',
//    taskTypeID: 1,
//    taskStatusID: 1,
//  ),
//  const Task(
//    id: '4',
//    location:'01-01-04',
//    taskTypeID: 1,
//    taskStatusID: 1,
//  ),
//  const Task(
//    id: '5',
//    location:'01-01-05',
//    taskTypeID: 1,
//    taskStatusID: 1,
//  ),
//  const Task(
//    id:'6',
//    location:'01-01-06',
//    taskTypeID: 1,
//    taskStatusID: 1,
//  ),
//  const Task(
//    id:'7',
//    location:'01-01-07',
//    taskTypeID: 1,
//    taskStatusID: 1,
//  ),
//];