import 'dart:async';
import 'package:techviz/repository/async/IRouting.dart';
import 'package:techviz/repository/async/Routing.dart';

class DeviceRouting implements IRouting {
  String routingPattern = "mobile.device";

  @override
  void ListenQueue(Function callback, {Function callbackError}) {
    Routing().ListenQueue(routingPattern, callback, callbackError: callbackError);
  }

  @override
  Future PublishMessage(dynamic message, {Function callback, Function callbackError}) {
    return Routing().PublishMessage(routingPattern, message, callback: callback, callbackError: callbackError);
  }
}