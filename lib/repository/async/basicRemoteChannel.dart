import 'dart:async';
import 'dart:convert';

import 'package:dart_amqp/dart_amqp.dart';
import 'package:techviz/repository/session.dart';

class BasicRemoteChannel<T>  {
  Future<T> publishMessage(dynamic object, String routingKeyName, String exchangeName, {String queueName, String replyRoutingKeyName, Function parser}) {

    final Completer<T> _completer = Completer();

    Session().rabbitmqClient.then((Client client){
      return client.channel();
    }).then((Channel channel){
      return channel.exchange(exchangeName, ExchangeType.TOPIC, durable: true );
    }).then((Exchange exchange){
      MessageProperties props = MessageProperties();
      props.persistent = true;
      props.contentType = 'application/json';

      bool listenForResponse = queueName!= null && parser!=null;

      if(listenForResponse){
        exchange.channel.queue(queueName, autoDelete: true).then((Queue queue){
          return queue.bind(exchange, routingKeyName);
        }).then((Queue queue){
          return queue.consume();
        }).then((Consumer consumer){

          consumer.listen((AmqpMessage message) {
            if(message.routingKey == routingKeyName){
              Map<String, dynamic> jsonResult = message.payloadAsJson;
              return consumer.cancel().then((Consumer consumer){
                return _completer.complete(parser(jsonResult) as T);
              });
            }
          });
          exchange.publish(JsonEncoder().convert(object), routingKeyName, properties: props);
        });
      }
      else{
        exchange.publish(JsonEncoder().convert(object), routingKeyName, properties: props);
        return _completer.complete();
      }
    });

    return _completer.future;
  }

  void publishSimpleMessage(dynamic object, String routingKeyName, String exchangeName) {

    Session().rabbitmqClient.then((Client client){
      return client.channel();
    }).then((Channel channel){
      return channel.exchange(exchangeName, ExchangeType.TOPIC, durable: true );
    }).then((Exchange exchange){
      MessageProperties props = MessageProperties();
      props.persistent = true;
      props.contentType = 'application/json';

      exchange.publish(JsonEncoder().convert(object), routingKeyName, properties: props);
    });
  }
}