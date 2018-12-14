import 'dart:async';

import 'package:techviz/repository/async/basicRemoteChannel.dart';
import 'package:techviz/repository/async/messageClient.dart';

class UserSectionMessage implements IMessageClient<dynamic,void> {
  @override
  Future<void> publishMessage(dynamic object, {String deviceID}) {
    return BasicRemoteChannel<void>().publishMessage(
        object,
        "mobile.section.update",
        "techViz",
    );
  }

  @override
  void bind(Function callbackFnc) {
    // TODO: implement bind
  }
}