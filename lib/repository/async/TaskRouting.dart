import 'dart:async';
import 'package:techviz/model/task.dart';
import 'package:techviz/repository/async/MessageClient.dart';

abstract class ITaskRouting{
  StreamController ListenQueue(Function onData, {Function onError, Function onCancel});
  Future PublishMessage(dynamic message, {String customRoutingPattern});
  Task parser(dynamic json);
}

class TaskRouting implements ITaskRouting{
  String routingPattern = "mobile.task";

  @override
  StreamController ListenQueue(Function onData, {Function onError, Function onCancel}) {
    return MessageClient().ListenQueue(routingPattern, onData, onError: onError, timeOutEnabled: false);
  }

  @override
  Future PublishMessage(dynamic message, {String customRoutingPattern}) {
    return MessageClient().PublishMessage(message, routingPattern, wait: false);
  }

  @override
  Task parser(dynamic json){
    return Task(
      id: json['_ID'] as String,
      dirty: false,
      version: json['_version'] as int,
      userID: json['userID'] as String,
      location:  json['location'] as String,
      taskAssigned: json['taskAssigned'] as DateTime,
      taskCreated: json['taskAssigned'] as DateTime,
      taskUrgencyID: int.parse(json['taskUrgencyID'] as String),
      taskStatusID : int.parse(json['taskStatusID'] as String),
      taskTypeID : int.parse(json['taskTypeID'] as String)
    );
  }
}