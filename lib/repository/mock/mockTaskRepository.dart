import 'dart:async';

import 'package:techviz/model/task.dart';
import 'package:techviz/model/taskStatus.dart';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/repository/iTaskRepository.dart';

class MockTaskRepository implements ITaskRepository{

  @override
  Future<List<dynamic>> fetch() {
    return Future.value();
  }

  @override
  Future<List<Task>> getTaskList() {
    return Future.value(kTask);
  }



}

const kTask = const <Task>[
  const Task(
    id: '1',
    location:'01-01-01',
    taskType: TaskType(id: '1',description: 'Jackpot'),
    taskStatus: TaskStatus(id:'1',description: 'Aknowledged'),
  ),
  const Task(
    id: '2',
    location: '01-01-02',
    taskType: TaskType(id:'1',description: 'Jackpot'),
    taskStatus: TaskStatus(id:'1',description: 'Aknowledged'),
  ),
  const Task(
    id:  '3',
    location:'01-01-03',
    taskType: TaskType(id:'1',description: 'Jackpot'),
    taskStatus: TaskStatus(id:'1',description: 'Aknowledged'),
  ),
  const Task(
    id: '4',
    location:'01-01-04',
    taskType: TaskType(id:'1',description: 'Jackpot'),
    taskStatus: TaskStatus(id:'1',description: 'Aknowledged'),
  ),
  const Task(
    id: '5',
    location:'01-01-05',
    taskType: TaskType(id:'1',description: 'Jackpot'),
    taskStatus: TaskStatus(id:'1',description: 'Aknowledged'),
  ),
  const Task(
    id:'6',
    location:'01-01-06',
    taskType: TaskType(id:'1',description: 'Jackpot'),
    taskStatus: TaskStatus(id:'1',description: 'Aknowledged'),
  ),
  const Task(
    id:'7',
    location:'01-01-07',
    taskType: TaskType(id:'1',description: 'Jackpot'),
    taskStatus: TaskStatus(id:'1',description: 'Aknowledged'),
  ),
];