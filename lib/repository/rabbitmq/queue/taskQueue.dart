import 'dart:async';

import 'package:dart_amqp/dart_amqp.dart';
import 'package:event_bus/event_bus.dart';
import 'package:techviz/model/task.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/local/taskTable.dart';
import 'package:techviz/repository/rabbitmq/queue/remoteQueue.dart';
import 'package:techviz/repository/session.dart';
import 'package:techviz/repository/taskRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class TaskQueue implements IRemoteQueue<dynamic>{
  Consumer consumer;
  Queue queue;

  static final TaskQueue _singleton = TaskQueue._internal();
  factory TaskQueue() {
    return _singleton;
  }

  TaskQueue._internal() {}

  void StopListening() async{
    if(consumer!=null){
      consumer.cancel().then((Consumer consumer){
        print('Consumer ${consumer.toString()} cancalled.');
      });
    }
  }

  @override
  Future listen(RemoteQueueCallback<Task> callback) async {
    Session session = Session();
    DeviceInfo info = await Utils.deviceInfo;

    String queueName = "mobile.${info.DeviceID}";
    String routingKeyName = "mobile.task.${info.DeviceID}";

    Client rabbitmqClient = await session.rabbitmqClient;
    Channel channel = await rabbitmqClient.channel();
    Exchange exchange = await channel.exchange("techViz", ExchangeType.TOPIC, durable: true);

    queue = await channel.queue(queueName, autoDelete: true).then((Queue queue){
      return queue.bind(exchange, routingKeyName);
    });

    consumer = await queue.consume();

    print('listening to the queue {$queueName} and routing key ${routingKeyName}');

    consumer.listen((AmqpMessage message) async {
      Map<String, dynamic> jsonResult = message.payloadAsJson;
      print('Task received ====> ID: ${jsonResult['_ID']}         Location: ${jsonResult['location']}         StatusID: ${jsonResult['taskStatusID']}         UserID: ${jsonResult['userID']}');

      String deviceID = jsonResult['deviceID'];
      if(deviceID == deviceID){

        LocalRepository localRepo = LocalRepository();
        await localRepo.open();

        Map<String, dynamic> map = Map<String, dynamic>();
        map['_ID'] = jsonResult['_ID'] as String;
        map['_Version'] = jsonResult['_version'];
        map['_Dirty'] = false;
        map['UserID'] = jsonResult['userID'];
        map['MachineID'] = jsonResult['machineID'];
        map['Location'] = jsonResult['location'];
        map['TaskStatusID'] = jsonResult['taskStatusID'];
        map['TaskTypeID'] = jsonResult['taskTypeID'];
        map['TaskCreated'] = jsonResult['taskCreated'].toString();
        map['TaskAssigned'] = jsonResult['taskAssigned'].toString();
        map['PlayerID'] = jsonResult['playerID'];
        map['Amount'] = jsonResult['amount'] == null ? 0 : jsonResult['amount'];
        map['EventDesc'] = jsonResult['eventDesc'];
        map['PlayerID'] = jsonResult['playerID'];
        map['PlayerFirstName'] = jsonResult['firstName'];
        map['PlayerLastName'] = jsonResult['lastName'];
        map['PlayerTier'] = jsonResult['tier'];
        map['PlayerTierColorHex'] = jsonResult['tierColorHex'];

        await TaskTable.insertOrUpdate(localRepo.db, [map]);

        Task taskUpdated = await TaskRepository().getTask(jsonResult['_ID'] as String);
        callback(taskUpdated);
      }

    });
  }
}