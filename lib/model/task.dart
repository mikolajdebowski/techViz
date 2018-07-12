import 'package:techviz/model/taskStatus.dart';
import 'package:techviz/model/taskType.dart';

class Task{
  final String id;
  final String location;
  final String machineId;
  final TaskType taskType;
  final TaskStatus taskStatus;

  const Task({this.id, this.location, this.taskType, this.taskStatus, this.machineId});

}
