import 'dart:async';
import 'package:techviz/model/task.dart';
import 'package:techviz/repository/async/MessageClient.dart';

class TaskRouting {
  String routingPattern = "mobile.task";

  StreamController ListenQueue(Function onData, {Function onError, Function onCancel}) {
    return MessageClient().ListenQueue(routingPattern, onData, onError: onError, timeOutEnabled: false);
  }

  Future PublishMessage(dynamic message) {
    return MessageClient().PublishMessage(message, routingPattern, wait: false);
  }

  Task parser(dynamic json){
    return Task(
      id: json['_ID'] as String,
      dirty: false,
      version: json['_version'] as int,
      userID: json['userID'] as String,
      location:  json['location'] as String,
      taskAssigned: json['taskAssigned'] as DateTime,
      taskCreated: json['taskAssigned'] as DateTime,
      taskUrgencyID: 2,
      taskStatusID : int.parse(json['taskStatusID'] as String),
      taskTypeID : int.parse(json['taskTypeID'] as String)
    );
  }
}