import 'dart:async';
import 'package:techviz/repository/rabbitmq/channel/basicRemoteChannel.dart';
import 'package:techviz/repository/rabbitmq/channel/iRemoteChannel.dart';

class DeviceChannel extends BasicRemoteChannel implements IRemoteChannel<dynamic> {
  @override
  Future submit(dynamic object) async {
    return super.remoteSubmit(object, "mobile.device.update", "techViz");
  }
}