import 'dart:async';

import 'package:techviz/repository/rabbitmq/channel/basicRemoteChannel.dart';
import 'package:techviz/repository/rabbitmq/channel/iRemoteChannel.dart';
import 'package:techviz/model/user.dart';

class UserChannel implements IRemoteChannel<dynamic,User> {

  @override
  Future<User> publishMessage(dynamic object, {String deviceID}) {
    return BasicRemoteChannel<User>().publishMessage(
        object,
        "mobile.user.update",
        "techViz",
        parser: parser,
        queueName: deviceID != null ? "mobile.${deviceID}" : null,
        replyRoutingKeyName: deviceID != null ? "mobile.user.${deviceID}" : null
    );
  }

  User parser(Map<String,Object> map){
    return User(UserID: "123", UserStatusID: 2);
  }
}

