import 'dart:async';

import 'package:dart_amqp/dart_amqp.dart';
import 'package:techviz/repository/rabbitmq/channel/remoteChannel.dart';
import 'package:techviz/repository/session.dart';
import 'dart:convert';

class DeviceChannel implements IRemoteChannel<dynamic> {
  @override
  Future submit(dynamic object) async {
    Session session = Session();
    Client rabbitmqClient = await session.rabbitmqClient;
    Channel channel = await rabbitmqClient.channel();
    Exchange exchange = await channel.exchange("techViz", ExchangeType.TOPIC, durable: true );

    MessageProperties props = MessageProperties();
    props.persistent = true;

    await exchange.publish(JsonEncoder().convert(object), "mobile.device.update", properties: props);
    channel.close();
  }
}