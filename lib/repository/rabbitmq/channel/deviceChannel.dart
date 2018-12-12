import 'dart:async';
import 'package:techviz/repository/rabbitmq/channel/basicRemoteChannel.dart';
import 'package:techviz/repository/rabbitmq/channel/iRemoteChannel.dart';

class DeviceChannel implements IRemoteChannel<dynamic,void> {
  @override
  Future<void> publishMessage(dynamic object, {String deviceID}) {
    return BasicRemoteChannel<void>().publishMessage(
        object,
        "mobile.device.update",
        "techViz"
    );
  }
}