import 'dart:async';
import 'package:techviz/repository/rabbitmq/channel/basicRemoteChannel.dart';
import 'package:techviz/repository/rabbitmq/channel/iRemoteChannel.dart';

class TaskChannel extends BasicRemoteChannel implements IRemoteChannel<dynamic> {
  @override
  Future submit(dynamic object) async {
    return await super.remoteSubmit(object, "mobile.task.update", "techViz");
  }
}