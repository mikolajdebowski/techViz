import 'dart:async';

import 'package:techviz/repository/rabbitmq/channel/remoteChannel.dart';

class DeviceChannel implements IRemoteChannel<dynamic>{
  @override
  Future submit(dynamic object) {
    throw UnimplementedError();
  }
}