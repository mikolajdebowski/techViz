import 'dart:async';

import 'package:dart_amqp/dart_amqp.dart';
import 'package:event_bus/event_bus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techviz/config.dart';
import 'package:techviz/model/user.dart';

class Session {
  User user;
  EventBus eventBus;
  Client _rabbitmqClient;

  static final Session _singleton = Session._internal();
  factory Session() {
    return _singleton;
  }

  Session._internal() {
    print('Session instance');
  }


  Future<Client> get rabbitmqClient async{
    if(_rabbitmqClient==null){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String host = prefs.getString(Config.SERVERURL);
      Uri hostURI =  Uri.parse(host);

      ConnectionSettings settings = ConnectionSettings(host: hostURI.host, authProvider: AmqPlainAuthenticator("test", "test"));
      _rabbitmqClient = Client(settings: settings);
    }

    return _rabbitmqClient;
  }




  void clear(){
    user = null;
    //disconnectAsyncData();
  }

  void connectAsyncData() async {
//    print('Session -> connecting to the RabbitMQ');
//    eventBus = EventBus();
//
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    String host = prefs.getString(Config.SERVERURL);
//    Uri hostURI =  Uri.parse(host);
//
//    ConnectionSettings settings = ConnectionSettings(host: hostURI.host, authProvider: AmqPlainAuthenticator("test", "test"));
//    _rabbitmqClient = Client(settings: settings);

//    _rabbitmqClient
//        .channel()
//        .then((Channel channel) {
//          _channel = channel;
//
//          listenTaskQueue();
//          changeUserStatusQueue();
//        });
  }

//  void listenTaskQueue(){
//    String taskNewQueue = "task.create.${user.UserID}";
//
//    _channel.queue(taskNewQueue, durable: true).then((Queue queue) {
//      _taskQueue = queue;
//
//      print('Session -> Task Queue created => ${queue.name}');
//
//      return _taskQueue.consume();
//    }).then((Consumer consumer) => consumer.listen((AmqpMessage message) {
//      if(message.payload.length==0)
//        return;
//
//      print("[x] Received on queue ${taskNewQueue} >  ${message.payloadAsString}");
//
//      Map<String, dynamic> payload = message.payloadAsJson;
//
//      Task task = Task(
//          id: payload['_ID'].toString(),
//          location: payload['Location'].toString(),
//          taskStatusID: payload['TaskStatusID'] as int,
//          taskTypeID: payload['TaskTypeID'] as int,
//          taskCreated: DateTime.parse(payload['TaskCreated'] as String)
//      );
//
//      eventBus.fire(task);
//    }));
//  }

//  void changeUserStatusQueue() async {
////    String queueName = "user.update.$userID";
////    int messageID = 123;//Message(UpdateUserStatus);
////    Exchange exc = await _channel.exchange(name, type);
////    MessageProperties props = MessageProperties.persistentMessage();
////    props.messageId = messageID.toString();
////
////    exc.publish(newStatusID, routingKey, properties: props);
////
////    Consumer consumer = exc.bindPrivateQueueConsumer(routingKeys)
////    consumer.listen((AmqpMessage message) {
////
////      int messageIDReplied = message.properties.replyTo;
////
////    });
//  }

//
//  void disconnectAsyncData() {
//    eventBus = null;
//    try{
//      if(_taskQueue!=null){
//        _taskQueue.delete();
//        print('Session -> Task Queue deleted ${_taskQueue.name}');
//        _taskQueue = null;
//      }
//
//      if(_channel!=null){
//        _channel.close();
//        _channel = null;
//      }
//
//      if(rabbitmqClient!=null){
//        rabbitmqClient.close();
//
//        print('Session -> RabbitMQ disconnected');
//      }
//    }
//    catch (err){
//      print(err);
//    }
//
//  }
}
