import 'dart:async';

import 'package:techviz/model/task.dart';
import 'package:techviz/repository/async/TaskRouting.dart';

class TaskRoutingMock implements TaskRouting{
  @override
  String routingPattern;

  @override
  StreamController ListenQueue(Function onData, {Function onError, Function onCancel}) {
    return null;
  }

  @override
  Future PublishMessage(dynamic message, {String customRoutingPattern}) {
    return null;
  }

  @override
  Task parser(dynamic json) {
    return null;
  }


}