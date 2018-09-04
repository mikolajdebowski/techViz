import 'dart:async';

import 'package:techviz/repository/rabbitmq/queue/remoteQueue.dart';

class TaskQueue implements IRemoteQueue<dynamic>{
  @override
  Future listen() {
    throw UnimplementedError();
  }
}