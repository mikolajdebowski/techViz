import 'dart:async';

import 'package:techviz/model/user.dart';
import 'package:techviz/repository/rabbitmq/channel/remoteChannel.dart';

class UserChannel implements IRemoteChannel<User>{
  @override
  Future submit(User object) {
    // TODO: implement submit
  }
}