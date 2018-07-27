import 'package:dart_amqp/dart_amqp.dart';
import 'package:event_bus/event_bus.dart';
import 'package:techviz/model/task.dart';

class Session {
  String userID = "57b3a85dc4b-15f555106cc";
  EventBus eventBus;
  Client rabbitmqClient;
  ConnectionSettings settings = ConnectionSettings(host: "fig.internal.bis2.net", authProvider: AmqPlainAuthenticator("admin", "admin123"));

  static final Session _singleton = Session._internal();

  factory Session() {
    print('Session started');
    return _singleton;
  }

  Session._internal() {
    bindQueues();
  }

  void bindQueues() {
    eventBus = EventBus();

    rabbitmqClient = Client(settings: settings);

    String taskNewQueue = "task.create.$userID";
    print('Task Queue => ' + taskNewQueue);

    rabbitmqClient
        .channel()
        .then((Channel channel) => channel.queue(taskNewQueue, durable: true))
        .then((Queue queue) => queue.consume())
        .then((Consumer consumer) => consumer.listen((AmqpMessage message) {

              if(message.payload.length==0)
                return;

              print("[x] Received on queue ${taskNewQueue} >  ${message.payloadAsString}");


              Map<String, dynamic> payload = message.payloadAsJson;

              Task task = Task(
                        id: payload['_ID'].toString(),
                        location: payload['Location'].toString(),
                        taskStatusID: payload['TaskStatusID'] as int,
                        taskTypeID: payload['TaskTypeID'] as int,
                        taskCreated: DateTime.parse(payload['TaskCreated'] as String)
                        );

              eventBus.fire(task);
            }));
  }
}
