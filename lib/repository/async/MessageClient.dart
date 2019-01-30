import 'dart:async';
import 'dart:convert';

import 'package:dart_amqp/dart_amqp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techviz/config.dart';

class MessageClient{
  static final MessageClient _instance = MessageClient._internal();
  Client _rabbitmqClient;
  String _exchangeName;

  factory MessageClient() {
    return _instance;
  }

  MessageClient._internal() {

  }

  Future Init(String exchangeName) async{
    print('MessageClient: Init');

    _exchangeName = exchangeName;
    Completer<void> _completer = Completer<void>();
    _rabbitmqClient = null;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String host = prefs.getString(Config.SERVERURL);
    Uri hostURI =  Uri.parse(host);

    ConnectionSettings settings = ConnectionSettings(host: hostURI.host, authProvider: AmqPlainAuthenticator("mobile", "mobile"));
    settings.maxConnectionAttempts = 1;

    _rabbitmqClient = Client(settings: settings);
    _rabbitmqClient.connect().then((dynamic client){
      print('RabbitMQ connected');
      return _completer.complete();
    }).catchError((dynamic e){
      print('RabbitMQ error: '+ e.toString());
      return _completer.completeError(e);
    });

    return _completer.future;
  }

  Future<Exchange> GetExchange(){
    return _rabbitmqClient.channel().then((Channel _channel) {
      return _channel.exchange(_exchangeName, ExchangeType.TOPIC, durable: true);
    });
  }

  Future<Consumer> GetConsumerForQueue(String queueName, String routingKeyPattern){
    Exchange _exchange;
    return GetExchange().then((Exchange exchange){
      _exchange = _exchange;
      return exchange.channel.queue(queueName, autoDelete: false, durable: true);
    }).then((Queue queue) {
      return queue.bind(_exchange, routingKeyPattern);
    }).then((Queue queueBinded){
      return queueBinded.consume();
    });
  }


  Future PublishMessage(dynamic object, String routingKeyName){
    Completer<void> _completer = Completer<void>();

    _rabbitmqClient.channel().then((Channel _channel) {
      return _channel.exchange(_exchangeName, ExchangeType.TOPIC, durable: true);
    }).then((Exchange exchange){
      MessageProperties props = MessageProperties();
      props.persistent = true;
      props.contentType = 'application/json';

      exchange.publish(JsonEncoder().convert(object), routingKeyName, properties: props);

      _completer.complete();
    }).timeout(Duration(seconds: 30), onTimeout: (){
      _completer.completeError(TimeoutException('Timeout while creating channel'));
    }).catchError((dynamic e){
      _completer.completeError(e);
    });

    return _completer.future;
  }
}