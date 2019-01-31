import 'dart:async';
import 'package:techviz/repository/async/IRouting.dart';
import 'package:techviz/repository/async/MessageClient.dart';

class DeviceRouting implements IRouting {
  String routingPattern = "mobile.device";

  @override
  void ListenQueue(Function callback, {Function callbackError}) {
    MessageClient().ListenQueue(routingPattern, callback, callbackError: callbackError);
  }

  @override
  Future PublishMessage(dynamic message, {Function callback, Function callbackError}) {
    return MessageClient().PublishMessage(message, routingPattern, callback: callback, callbackError: callbackError);
  }
}