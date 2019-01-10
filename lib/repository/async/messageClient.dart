import 'dart:async';
import 'dart:convert';
import 'package:dart_amqp/dart_amqp.dart';
import 'package:techviz/repository/session.dart';

class MessageClient {
  Exchange exchange;
  Channel channel;
  Queue queue;
  Consumer consumer;
  List<RoutingKeyCallback> callbacks;

  static final MessageClient _singleton = MessageClient._internal();
  factory MessageClient() {
    return _singleton;
  }

  MessageClient._internal() {
    callbacks = [];
  }

  Future init(String deviceID) {
    String queueName = "mobile.${deviceID}";

    Completer<void> _completer = Completer();

    Session().rabbitmqClient.then((Client client) {
      return client.channel();
    }).then((Channel _channel) {
      channel = _channel;
      return channel.exchange("techViz", ExchangeType.TOPIC, durable: true);
    }).then((Exchange _exchange) {
      exchange = _exchange;
      return channel.queue(queueName, autoDelete: true);
    }).then((Queue _queue) {
      queue = _queue;
      return queue.consume();
    }).then((Consumer _consumer) {
      consumer = _consumer;
      _completer.complete();
    });

    return _completer.future;
  }

  void publishMessage(dynamic object, String routingKeyName) {
    MessageProperties props = MessageProperties();
    props.persistent = true;
    props.contentType = 'application/json';

    exchange.publish(JsonEncoder().convert(object), routingKeyName, properties: props);
  }

  Future unbindRoutingKey(String routingKeyName) {
    callbacks.removeWhere((RoutingKeyCallback rkc) => rkc.routingKeyName == routingKeyName);
    return queue.unbind(exchange, routingKeyName).then<Queue>((Queue _queue) {
      queue = _queue;
      return queue;
    });
  }

  Future bindRoutingKey(RoutingKeyCallback routingKeyCallback) {
    callbacks.removeWhere((RoutingKeyCallback rkc) => rkc.routingKeyName == routingKeyCallback.routingKeyName);
    callbacks.add(routingKeyCallback);

    return queue.bind(exchange, routingKeyCallback.routingKeyName).then<Queue>((Queue _queue) {
      queue = _queue;
      return queue;
    });
  }

  void listen() {
    consumer.listen((AmqpMessage message) {
      if (message.routingKey == null) return;

      var where = callbacks.where((RoutingKeyCallback rkc) => rkc.routingKeyName == message.routingKey);
      if (where != null && where.length > 0) {
        RoutingKeyCallback callback = where.first;

        Map<String, dynamic> jsonResult = message.payloadAsJson as Map<String, dynamic>;

        //print("PAYLOAD: ${jsonResult}");

        callback.callbackFunction(jsonResult);
      }
    });
  }

  void stopListening() async {
    if (consumer != null) {
      consumer.cancel().then((Consumer consumer) {
        print('Consumer ${consumer.toString()} cancalled.');
      });
    }
  }
}

class RoutingKeyCallback {
  int callbackId;
  String routingKeyName;
  Function callbackFunction;
  Function mapper;
}

abstract class IMessageClient<T,X>{
  Future<X> publishMessage(T object, {String deviceID});
  void bind(Function callbackFnc);
}