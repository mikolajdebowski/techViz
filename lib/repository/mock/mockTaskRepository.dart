import 'dart:async';

import 'package:techviz/model/task.dart';
import 'package:techviz/model/taskStatus.dart';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/repository/common/IRepository.dart';

class MockTaskRepository implements IRepository<Task>{
  @override
  Future<List<Task>> fetch() {
    return new Future.value(kTask);
  }
}

const kTask = const <Task>[
  const Task(
    id: '1',
    location:'01-01-01',
    taskType: TaskType('1','Jackpot'),
    taskStatus: TaskStatus('1','Aknowledged'),
  ),
  const Task(
    id: '2',
    location: '01-01-02',
    taskType: TaskType('1','Jackpot'),
    taskStatus: TaskStatus('1','Aknowledged'),
  ),
  const Task(
    id:  '3',
    location:'01-01-03',
    taskType: TaskType('1','Jackpot'),
    taskStatus: TaskStatus('1','Aknowledged'),
  ),
  const Task(
    id: '4',
    location:'01-01-04',
    taskType: TaskType('1','Jackpot'),
    taskStatus: TaskStatus('1','Aknowledged'),
  ),
  const Task(
    id: '5',
    location:'01-01-05',
    taskType: TaskType('1','Jackpot'),
    taskStatus: TaskStatus('1','Aknowledged'),
  ),
  const Task(
    id:'6',
    location:'01-01-06',
    taskType: TaskType('1','Jackpot'),
    taskStatus: TaskStatus('1','Aknowledged'),
  ),
  const Task(
    id:'7',
    location:'01-01-07',
    taskType: TaskType('1','Jackpot'),
    taskStatus: TaskStatus('1','Aknowledged'),
  ),
];