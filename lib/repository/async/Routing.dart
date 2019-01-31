
import 'dart:async';

import 'package:dart_amqp/dart_amqp.dart';
import 'package:techviz/repository/async/MessageClient.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class Routing {

  Future ListenQueue(String routingPattern, Function callback, {Function callbackError, bool timeOutEnabled = true}) async {
    Completer<void> _completer = Completer<void>();

    DeviceInfo info = await Utils.deviceInfo;
    String routingKeyNameOfThisDevice = "${routingPattern}.${info.DeviceID}";

    if(timeOutEnabled){
      Future.delayed(Duration(seconds: 30), (){
        if(_completer.isCompleted)
          _completer.completeError(TimeoutException('timed out for listenqueue'));
      });
    }

    MessageClient().GetConsumerForQueue("${routingPattern}.update", routingKeyNameOfThisDevice).then((Consumer consumer){
      consumer.listen((AmqpMessage message){
        if (message.routingKey == null) return;//ignore the message
        if (message.routingKey != routingKeyNameOfThisDevice) return; //ignore the message

        Map<String, dynamic> jsonResult = message.payloadAsJson as Map<String, dynamic>;
        callback(jsonResult);

        _completer.complete();
      }).onError((dynamic error){
        print(error);
        if(callbackError!=null){
          callbackError(error);
        }
        _completer.completeError(error);
      });
    });
    return _completer.future;
  }

  Future PublishMessage(String routingPattern, dynamic object, {Function callback, Function callbackError, Function parser}) {
    return MessageClient().PublishMessage(object, routingPattern, callback: callback, callbackError: callbackError, parser: parser);
  }

}