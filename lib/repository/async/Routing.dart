
import 'package:dart_amqp/dart_amqp.dart';
import 'package:techviz/repository/async/MessageClient.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class Routing {

  Future ListenQueue(String routingPattern, Function callback, {Function callbackError}) async {
    DeviceInfo info = await Utils.deviceInfo;
    String routingKeyNameOfThisDevice = "${routingPattern}.${info.DeviceID}";

    MessageClient().GetConsumerForQueue("${routingPattern}.update", routingKeyNameOfThisDevice).then((Consumer consumer){
      consumer.listen((AmqpMessage message){
        if (message.routingKey == null) return;//ignore the message
        if (message.routingKey != routingKeyNameOfThisDevice) return; //ignore the message

        Map<String, dynamic> jsonResult = message.payloadAsJson as Map<String, dynamic>;
        callback(jsonResult);

      }).onError((dynamic error){
        print(error);
        if(callbackError!=null){
          callbackError(error);
        }
      });
    });
  }

  Future PublishMessage(String routingPattern, dynamic object) {
    return MessageClient().PublishMessage(object, "${routingPattern}.update");
  }

}