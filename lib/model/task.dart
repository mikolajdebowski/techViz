import 'package:techviz/model/taskStatus.dart';
import 'package:techviz/model/taskType.dart';

class Task {
  final String id;
  final String location;
  final String machineId;
  final int taskTypeID;
  final int taskStatusID;
  final DateTime taskCreated;
  final DateTime taskAssigned;
  final double amount;
  final String eventDesc;

  const Task({this.id, this.location, this.taskTypeID, this.taskStatusID, this.machineId, this.taskCreated, this.taskAssigned, this.amount, this.eventDesc});

}
