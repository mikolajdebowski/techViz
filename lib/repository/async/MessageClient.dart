import 'dart:async';
import 'dart:convert';

import 'package:dart_amqp/dart_amqp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techviz/config.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class MessageClient {
  static final MessageClient _instance = MessageClient._internal();
  Client _rabbitmqClient;
  String _exchangeName;

  factory MessageClient() {
    return _instance;
  }

  MessageClient._internal() {}

  Future Init(String exchangeName) async {
    print('MessageClient: Init');

    _exchangeName = exchangeName;
    Completer<void> _completer = Completer<void>();
    _rabbitmqClient = null;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String host = prefs.getString(Config.SERVERURL);
    Uri hostURI = Uri.parse(host);

    ConnectionSettings settings = ConnectionSettings(host: hostURI.host, authProvider: AmqPlainAuthenticator("mobile", "mobile"));
    settings.maxConnectionAttempts = 1;

    _rabbitmqClient = Client(settings: settings);
    _rabbitmqClient.connect().then((dynamic client) {
      print('RabbitMQ connected');
      return _completer.complete();
    }).catchError((dynamic e) {
      print('RabbitMQ error: ' + e.toString());
      return _completer.completeError(e);
    });

    return _completer.future;
  }

  Future<Exchange> GetExchange() {
    return _rabbitmqClient.channel().then((Channel _channel) {
      return _channel.exchange(_exchangeName, ExchangeType.TOPIC, durable: true);
    });
  }

  Future<Consumer> GetConsumerForQueue(String queueName, String routingKeyPattern) {
    Exchange _exchange;
    return GetExchange().then((Exchange exchange) {
      _exchange = _exchange;
      return exchange.channel.queue(queueName, autoDelete: false, durable: true);
    }).then((Queue queue) {
      return queue.bind(_exchange, routingKeyPattern);
    }).then((Queue queueBinded) {
      return queueBinded.consume();
    });
  }

  Future PublishMessage(dynamic object, String routingKeyPattern, {Function callback, Function callbackError, Function parser}) async {
    Completer<void> _completer = Completer<void>();

    _rabbitmqClient.channel().then((Channel _channel) {
      return _channel.exchange(_exchangeName, ExchangeType.TOPIC, durable: true);
    }).then((Exchange exchange) async {
      if (callback != null) {
        var deviceInfo = await Utils.deviceInfo;

        String deviceRoutingKeyName = "${routingKeyPattern}.${deviceInfo.DeviceID}";
        String queueNameForCallback = "${routingKeyPattern}.update";

        Map<String,Object> args = Map<String,String>();
        args["x-dead-letter-exchange"] = "techViz.error";

        exchange.channel.queue(queueNameForCallback, autoDelete: false, durable: true, arguments: args).then((Queue queue) {
          return queue.bind(exchange, deviceRoutingKeyName);
        }).then((Queue queueBinded) {
          return queueBinded.consume();
        }).then((Consumer consumer){
          consumer.listen((AmqpMessage message) {

            consumer.cancel();

            if(parser==null){
              callback(message.payloadAsJson);
            }
            else{
              callback(parser(message.payloadAsJson));
            }

            if (!_completer.isCompleted) {

              _completer.complete(message.payloadAsJson);
            }
          }).onError((dynamic error) {
            callbackError(error);
          });
        });
      }


      MessageProperties props = MessageProperties();
      props.persistent = true;
      props.contentType = 'application/json';

      exchange.publish(JsonEncoder().convert(object), "${routingKeyPattern}.update", properties: props);

      if (callback == null) {
        _completer.complete();
      }
    }).timeout(Duration(seconds: 30), onTimeout: () {
      _completer.completeError(TimeoutException('Timeout while creating channel'));
    }).catchError((dynamic e) {
      _completer.completeError(e);
    });

    return _completer.future;
  }


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
}
