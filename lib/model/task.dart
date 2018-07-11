import 'package:techviz/model/taskStatus.dart';
import 'package:techviz/model/taskType.dart';

class Task{
  final String id;
  final TaskType taskType;
  final TaskStatus taskStatus;

  const Task(this.id, this.taskType, this.taskStatus);
}

const kTask = const <Task>[
  const Task(
      '01-01-01',
      TaskType('1','Jackpot'),
      TaskStatus('1','Aknowledged')
  ),
  const Task(
      '01-01-02',
      TaskType( '2', 'M. Failure'),
      TaskStatus('1','Aknowledged')
  ),
  const Task(
      '01-01-03',
      TaskType('3', 'Unknown'),
      TaskStatus('2','Pending')
  ),
];