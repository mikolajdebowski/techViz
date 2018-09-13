import 'dart:async';
import 'dart:convert';

import 'package:dart_amqp/dart_amqp.dart';
import 'package:techviz/repository/session.dart';

class BasicRemoteChannel  {
  Future remoteSubmit(dynamic object, String routingKeyName, String exchangeName) async {
    Session session = Session();
    Client rabbitmqClient = await session.rabbitmqClient;
    Channel channel = await rabbitmqClient.channel();
    Exchange exchange = await channel.exchange(exchangeName, ExchangeType.TOPIC, durable: true );

    MessageProperties props = MessageProperties();
    props.persistent = true;
    props.contentType = 'application/json';

    await exchange.publish(JsonEncoder().convert(object), routingKeyName, properties: props);
    channel.close();
  }
}