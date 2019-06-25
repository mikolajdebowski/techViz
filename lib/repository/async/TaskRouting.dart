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
    print(json);
    return Task(
      id: json['_ID'],
      dirty: 0,
      version: json['_version'] as int,
      userID: json['userID'],
      location:  json['location'],
      taskAssigned: DateTime.parse(json['taskCreated'] as String),
      taskCreated: DateTime.parse(json['taskAssigned'] as String),
      taskUrgencyID: json['taskUrgencyID'],
      taskStatusID : json['taskStatusID'],
      taskTypeID : json['taskTypeID'],
      eventDesc: json['eventDesc'],
    );
  }
}