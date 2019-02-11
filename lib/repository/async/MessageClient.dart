import 'dart:async';
import 'dart:convert';
import 'package:dart_amqp/dart_amqp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techviz/config.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';
import 'package:flutter/services.dart' show rootBundle;

class MessageClient {
  static final MessageClient _instance = MessageClient._internal();
  Client _rabbitmqClient;
  String _exchangeName = null;
  Duration _timeoutDuration = Duration(seconds: 10);
  Consumer _consumer;
  Exchange _exchange;

  Map<String, List<StreamController<AmqpMessage>>> _mapStreamControllers;
  String _deviceID;

  factory MessageClient() {
    return _instance;
  }

  MessageClient._internal() {



  }

  Future Init() async {
    print('MessageClient: Init');
    if(_exchangeName==null){
      //CONFIGURATION
      String loadedConfig = await rootBundle.loadString('assets/json/config.json');
      dynamic jsonConfig = jsonDecode(loadedConfig);
      _exchangeName = jsonConfig['rabbitmq']['exchange_name'] as String;
    }

    //DEVICEID
    DeviceInfo deviceInfo = await Utils.deviceInfo;
    _deviceID = deviceInfo.DeviceID;

    //UNIQUE DEVICE QUEUE
    String queueName = "mobile.${_deviceID}";

    Completer<void> _completer = Completer<void>();
    _rabbitmqClient = null;
    _mapStreamControllers = Map<String, List<StreamController<AmqpMessage>>>();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String host = prefs.getString(Config.SERVERURL);
    Uri hostURI = Uri.parse(host);

    ConnectionSettings settings = ConnectionSettings(host: hostURI.host, authProvider: AmqPlainAuthenticator("mobile", "mobile"));
    settings.maxConnectionAttempts = 1;

    _rabbitmqClient = Client(settings: settings);
    _rabbitmqClient.connect().then((dynamic whatever) {

      print('RabbitMQ connected');

      _rabbitmqClient.channel().then((Channel channel){
        return _getExchange(channel);
      }).then((Exchange exchange){
        print('Exchange/Channel OK');
        _exchange = exchange;
        return _exchange.channel.queue(queueName, autoDelete: true);
      }).then((Queue queue){
        return queue.consume();
      }).then((Consumer consumer){
        _consumer = consumer;
        _consumer.listen((AmqpMessage message){
          print('RoutingKey: ${message.routingKey}');
          print('Payload: ${message.payloadAsJson}');
          var mapEntry = _mapStreamControllers[message.routingKey];
          if(mapEntry!=null){
            mapEntry.forEach((StreamController ss){
              ss.add(message);
            });
          }
        });

        print('Listening to the queue : ${_consumer.queue.name}');

        return _completer.complete();
      });

    }).catchError((dynamic e) {
      print('RabbitMQ error: ' + e.toString());
      return _completer.completeError(e);
    });
    _rabbitmqClient.errorListener((dynamic error){
      print(error);
    });
    return _completer.future;
  }

  void ResetChannel() async{
    Channel channel = await _rabbitmqClient.channel();
    _exchange = await _getExchange(channel);
  }

  void _bindQueue(String routingKey) async{
    try{
      await _consumer.queue.bind(_exchange, routingKey);
    }
    catch(e){
      if(e.runtimeType == StateError){
        await Init();
        return await _bindQueue(routingKey);
      }
      else throw e;
    }
  }

  void _addRoutingKeyListener(String routingKey, StreamController<AmqpMessage> subscription) async{
    await _bindQueue(routingKey);

    if(!_mapStreamControllers.containsKey(routingKey)){
      _mapStreamControllers[routingKey] = [];
    }
    _mapStreamControllers[routingKey].add(subscription);
  }

  void _removeRoutingKeyListener(String routingKey){
    _consumer.queue.unbind(_exchange, routingKey);
    if(_mapStreamControllers.containsKey(routingKey)){
      _mapStreamControllers.remove(routingKey);
    }
  }

  Future<Exchange> _getDefaultExchange(Channel channel){
    return channel.exchange(_exchangeName, ExchangeType.TOPIC, durable: true);
  }



  Future<Exchange> _getExchange(Channel _channel)  {
    return _getDefaultExchange(_channel).timeout(_timeoutDuration).then((Exchange exchange) {
      print('channel OK');
      return Future.value(exchange);
    }).catchError((dynamic connError){
      print(connError);
      print('getting second channel');

      if(connError.runtimeType == TimeoutException || connError.runtimeType == ChannelException){
        return _rabbitmqClient.channel().timeout(_timeoutDuration, onTimeout: (){
          throw TimeoutException('Timeout after trying to create channel');
        }).then((Channel channel) {
          print('new channel instance');
          _channel = channel;
          return _getDefaultExchange(_channel).timeout(_timeoutDuration);
        });
      }
      else{
        throw connError;
      }
    });
  }


  Future PublishMessage(dynamic object, String routingKeyPattern, {bool wait : false, Function parser}) async {
    Completer<void> _completer = Completer<void>();
    _completer.future.timeout(_timeoutDuration, onTimeout: (){
      _completer.completeError(TimeoutException('Max connect timeout reached after ${_timeoutDuration.inSeconds} seconds.'));
    });

    String routingKey = '${routingKeyPattern}.${_deviceID}';

    if(wait!=null && wait){
      StreamController<AmqpMessage> sc = StreamController<AmqpMessage>();
      sc.stream.listen((AmqpMessage message){
        _removeRoutingKeyListener(routingKey);
        _completer.complete(parser == null ? message.payloadAsJson : parser(message.payloadAsJson));
      });
      _addRoutingKeyListener(routingKey, sc);
    }

    MessageProperties props = MessageProperties();
    props.persistent = true;
    props.contentType = 'application/json';
    _exchange.publish(JsonEncoder().convert(object), "${routingKeyPattern}.update", properties: props);

    if(!wait){
      _completer.complete();
    }

    return _completer.future;
  }



  StreamController ListenQueue(String routingKeyPattern, Function onData, {Function onError, bool timeOutEnabled = true}) {
    String routingKey = '${routingKeyPattern}.${_deviceID}';

    void onCancel(){
      _removeRoutingKeyListener(routingKey);
    }

    StreamController<AmqpMessage> sc = StreamController<AmqpMessage>(onCancel: onCancel);
    sc.stream.listen((AmqpMessage message){
      onData(message.payloadAsJson);
    });
    _addRoutingKeyListener(routingKey, sc);
    return sc;
  }


//
//  void _publishMessage(Exchange exchange, dynamic object, String routingKeyPattern){
//      MessageProperties props = MessageProperties();
//      props.persistent = true;
//      props.contentType = 'application/json';
//      exchange.publish(JsonEncoder().convert(object), "${routingKeyPattern}.update", properties: props);
//  }











  Future Close(){
    if(_rabbitmqClient!=null){
      return _rabbitmqClient.close();
    }
    return Future<dynamic>.value(true);
  }



//
//
//  Future PublishMessage(dynamic object, String routingKeyPattern, {bool wait : false, Function parser}) async {
//    Completer<void> _completer = Completer<void>();

//    _getExchange().then((Exchange exchange) async{
//
//      if(wait == false){  //NO WAIT, JUST PUBLISH AND COMPLETE
//        _publishMessage(exchange, object, routingKeyPattern);
//        _completer.complete();
//      }
//      else{
//
//        var deviceInfo = await Utils.deviceInfo;
//        String deviceRoutingKeyName = "${routingKeyPattern}.${deviceInfo.DeviceID}";
//        String queueName = "mobile.${deviceInfo.DeviceID}";
//
//        exchange.channel.queue(queueName, autoDelete: false).then((Queue queue) {
//          return queue.bind(exchange, deviceRoutingKeyName);
//        }).then((Queue queueBinded) {
//          return queueBinded.consume();
//        }).then((Consumer consumer){
//          consumer.listen((AmqpMessage message) {
//            if(message.routingKey == deviceRoutingKeyName){
//                print('RECEIVED with routingKey: ${message.routingKey}');
//                print('PAYLOAD: ${message.payloadAsJson}');
//                print('\n\n');
//
//                if (!_completer.isCompleted) {
//                  _completer.complete(parser!=null ? parser(message.payloadAsJson): message.payloadAsJson);
//                }
//              }
//          }).onError((dynamic listenError){
//            print(listenError);
//            _completer.completeError(listenError);
//          });
//          _publishMessage(exchange, object, routingKeyPattern);
//        });
//      }
//    }).catchError((dynamic channelError){
//      _completer.completeError(channelError);
//    });
//
//    return _completer.future;




//
//        if (callback == null) {
//          _publishMessage(exchange, object);
//          _completer.complete();
//        }
//        else{
//
//          var deviceInfo = await Utils.deviceInfo;
//
//          String deviceRoutingKeyName = "${routingKeyPattern}.${deviceInfo.DeviceID}";
//          String queueName = "mobile.${deviceInfo.DeviceID}";
//
//          exchange.channel.queue(queueName, autoDelete: false).then((Queue queue) {
//            return queue.bind(exchange, deviceRoutingKeyName);
//          }).then((Queue queueBinded) {
//            return queueBinded.consume();
//          }).then((Consumer consumer){
//            consumer.listen((AmqpMessage message) {
//
//              if(_completer.isCompleted){
//                consumer.cancel();
//              }
//
//              if(message.routingKey == deviceRoutingKeyName){
//                print('RECEIVED with routingKey: ${message.routingKey}');
//                print('PAYLOAD: ${message.payloadAsJson}');
//                print('\n\n');
//
//                consumer.cancel();
//
//                if (!_completer.isCompleted) {
//                  _completer.complete(parser!=null ? parser(message.payloadAsJson): message.payloadAsJson);
//                }
//              }
//
//            }).onError((dynamic error) {
//              callbackError(error);
//            });
//
//            _publishMessage(exchange, object);
//
//          });
//        }
//
//      }).timeout(Duration(seconds: 5), onTimeout: () {
//        throw TimeoutException('Timeout reached after 30 seconds.');
//      }).catchError((dynamic e) {
//        if(!_completer.isCompleted)
//          _completer.completeError(e);
//      });
//      return _completer.future;
//    };



//
//
//
//
//  }
//
//  Future<Consumer> ListenQueue(String routingKeyPattern, Function onData, {Function onError, bool timeOutEnabled = true})  {
//    Completer<Consumer> _completer = Completer<Consumer>();
//
//    if (timeOutEnabled) {
//      Future.delayed(Duration(seconds: 30), () {
//        if (_completer.isCompleted)
//          _completer.completeError(TimeoutException('timed out for listenqueue'));
//      });
//    }
//
//    _rabbitmqClient.channel().then((Channel _channel) {
//      return _channel.exchange(_exchangeName, ExchangeType.TOPIC, durable: true);
//    }).then((Exchange exchange) async {
//      if (onData != null) {
//        var deviceInfo = await Utils.deviceInfo;
//
//        String deviceRoutingKeyName = "${routingKeyPattern}.${deviceInfo.DeviceID}";
//        String queueName = "mobile.${deviceInfo.DeviceID}";
//
//        exchange.channel.queue(queueName, autoDelete: false).then((Queue queue) {
//          return queue.bind(exchange, deviceRoutingKeyName);
//        }).then((Queue queueBinded) {
//          return queueBinded.consume();
//        }).then((Consumer consumer) {
//
//          consumer.listen((AmqpMessage message) {
//
//            if(message.routingKey == deviceRoutingKeyName){
//              print('RECEIVED with routingKey: ${message.routingKey}');
//              print('PAYLOAD: ${message.payloadAsJson}');
//              print('\n\n');
//
//              onData(message.payloadAsJson);
//            }
//          }).onError((dynamic error) {
//            onError(error);
//          });
//          _completer.complete(consumer);
//        });
//      }
//    });
//
//    return _completer.future;
//  }

}
