import 'dart:async';
import 'package:dart_amqp/dart_amqp.dart';
import 'package:techviz/model/task.dart';
import 'package:techviz/repository/async/MessageClient.dart';

class TaskRouting {
  String routingPattern = "mobile.task";

  Future<Consumer> ListenQueue(Function onData, {Function onError, Function onCancel}) {
    return MessageClient().ListenQueue(routingPattern, onData, onError: onError, timeOutEnabled: false);
  }

  Future PublishMessage(dynamic message, {Function callback, Function callbackError}) {
    return MessageClient().PublishMessage(message, routingPattern, callback: callback, callbackError: callbackError, parser: parser);
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
      taskStatusID : int.parse(json['taskStatusID'] as String),
      taskTypeID : int.parse(json['taskTypeID'] as String)
    );
  }
}