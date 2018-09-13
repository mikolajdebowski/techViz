import 'dart:async';

import 'package:dart_amqp/dart_amqp.dart';
import 'package:techviz/model/task.dart';
import 'package:techviz/repository/rabbitmq/queue/remoteQueue.dart';
import 'package:techviz/repository/session.dart';
import 'package:techviz/repository/taskRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class TaskQueue implements IRemoteQueue<dynamic>{
  @override
  Future listen(RemoteQueueCallback<Task> callback) async {
    Session session = Session();
    DeviceInfo info = await Utils.deviceInfo;

    String routingKey = "mobile.task.${info.DeviceID}";
    print('listening to the routingKey ' + routingKey);

    Client rabbitmqClient = await session.rabbitmqClient;
    Channel channel = await rabbitmqClient.channel();
    Exchange exchange = await channel.exchange("techViz", ExchangeType.TOPIC, durable: true );

    Queue queue = await channel.queue(routingKey, autoDelete: true).then((Queue queue){
      return queue.bind(exchange, routingKey);
    });

    Consumer consumer = await queue.consume();
    consumer.listen((AmqpMessage message) async {
      Map<String, dynamic> jsonResult = message.payloadAsJson;
      print(jsonResult);

      String deviceID = jsonResult['deviceID'];
      if(deviceID == deviceID){
        String taskID = jsonResult['_ID'];
        int taskStatusID = jsonResult['taskStatusID'];
        await TaskRepository().update(taskID, taskStatusID: taskStatusID.toString(), markAsDirty: false);

        TaskRepository().getTask(taskID).then((Task task){
          callback(task);
        });
      }

    });
  }
}