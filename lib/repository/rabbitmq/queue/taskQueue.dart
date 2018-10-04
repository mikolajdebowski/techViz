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
  EventBus eventBus;
  static final TaskQueue _singleton = TaskQueue._internal();
  factory TaskQueue() {
    return _singleton;
  }

  TaskQueue._internal() {
    print('TaskQueue instance');
  }

  void StopListening() async{
    print('StopListening called');

    if(consumer!=null){
      consumer.cancel().then((Consumer consumer){
        print('Consumer canceled');

        queue.delete().then((Queue queue){
          print('Queue deleted');
        });
      });
    }
  }

  @override
  Future listen(RemoteQueueCallback<Task> callback) async {
    Session session = Session();
    DeviceInfo info = await Utils.deviceInfo;

    String routingKey = "mobile.task.${info.DeviceID}";
    print('listening to the routingKey ' + routingKey);

    Client rabbitmqClient = await session.rabbitmqClient;
    Channel channel = await rabbitmqClient.channel();
    Exchange exchange = await channel.exchange("techViz", ExchangeType.TOPIC, durable: true );

    queue = await channel.queue(routingKey, autoDelete: true).then((Queue queue){
      return queue.bind(exchange, routingKey);
    });

    consumer = await queue.consume();
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
        map['TaskCreated'] = DateTime.parse(jsonResult['taskCreated'].toString()).toLocal().toString();
        map['TaskAssigned'] = DateTime.parse(jsonResult['taskAssigned'].toString()).toLocal().toString();
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