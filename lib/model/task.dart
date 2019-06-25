import 'package:techviz/model/taskStatus.dart';
import 'package:techviz/model/taskType.dart';

import 'escalationPath.dart';

class Task {
  String id;
  int version;
  int dirty;
  String location;
  String machineId;
  String userID;

  TaskType taskType;
  int taskTypeID;
  TaskStatus taskStatus;
  int taskStatusID;

  int taskUrgencyID;

  DateTime taskCreated;
  DateTime taskAssigned;
  double amount;
  String eventDesc;
  String playerID;

  String playerFirstName;
  String playerLastName;
  String playerTier;
  String playerTierColorHEX;

  String urgencyHEXColor;





  String cancellationReason;
  EscalationPath escalationPath;
  TaskType escalationTaskType;
  String notes;

  Task({this.id, this.version, this.userID, this.dirty, this.location, this.taskType, this.taskStatus, this.machineId, this.taskCreated, this.taskAssigned, this.amount, this.eventDesc, this.playerID,
  this.playerFirstName, this.playerLastName, this.playerTier, this.playerTierColorHEX, this.urgencyHEXColor, this.taskTypeID, this.taskStatusID, this.taskUrgencyID});

}
