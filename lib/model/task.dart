import 'package:techviz/model/taskStatus.dart';
import 'package:techviz/model/taskType.dart';

class Task {
  final String id;
  final int version;
  final bool dirty;
  final String location;
  final String machineId;
  final String userID;

  final TaskType taskType;
  final TaskStatus taskStatus;
  final DateTime taskCreated;
  final DateTime taskAssigned;
  final double amount;
  final String eventDesc;
  final String playerID;

  final String playerFirstName;
  final String playerLastName;
  final String playerTier;
  final String playerTierColorHEX;

  final String urgencyHEXColor;

  const Task({this.id, this.version, this.userID, this.dirty, this.location, this.taskType, this.taskStatus, this.machineId, this.taskCreated, this.taskAssigned, this.amount, this.eventDesc, this.playerID,
  this.playerFirstName, this.playerLastName, this.playerTier, this.playerTierColorHEX, this.urgencyHEXColor});


}
