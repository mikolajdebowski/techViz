import 'dart:async';
import 'package:techviz/repository/async/MessageClient.dart';
import 'package:techviz/repository/async/OldRouting.dart';

class DeviceRouting implements OldRouting {
  String routingPattern = "mobile.device";

  @override
  void ListenQueue(Function callback, {Function callbackError}) {
    MessageClient().ListenQueue(routingPattern, callback, onError: callbackError);
  }

  @override
  Future PublishMessage(dynamic message) {
    return MessageClient().PublishMessage(message, routingPattern);
  }

}