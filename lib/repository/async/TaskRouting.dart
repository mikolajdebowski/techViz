import 'dart:async';
import 'package:techviz/model/task.dart';
import 'package:techviz/repository/async/IRouting.dart';
import 'package:techviz/repository/async/MessageClient.dart';

class UserRouting implements IRouting {
  String routingPattern = "mobile.task";

  @override
  void ListenQueue(Function callback, {Function callbackError}) {
    MessageClient().ListenQueue(routingPattern, callback, callbackError: callbackError);
  }

  @override
  Future PublishMessage(dynamic message, {Function callback, Function callbackError}) {
    return MessageClient().PublishMessage(message, routingPattern, callback: callback, callbackError: callbackError, parser: parser);
  }

  Task parser(dynamic json){
      /*
        taskMapped['TASKSTATUSID'] = task['taskStatusID'];
        taskMapped['TASKTYPEID'] = task['taskTypeID'];
      */
    return Task(
      id: json['_ID'] as String,
      dirty: false,
      version: json['_version'] as int,
      userID: json['userID'] as String,
      location:  json['location'] as String,
      taskAssigned: json['taskAssigned'] as DateTime,
      taskCreated: json['taskAssigned'] as DateTime
    );
  }


}