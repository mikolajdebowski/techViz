import 'dart:async';
import 'package:techviz/repository/async/messageClient.dart';
import 'package:techviz/model/user.dart';

class UserMessage implements IMessageClient<dynamic,User> {
  RoutingKeyCallback callback;

  @override
  Future<User> publishMessage(dynamic object, {String deviceID}) async{
    Completer<User> _completer = Completer();

    void callbackFunction(Map<String, dynamic> map){
      User user = fromMap(map);

      MessageClient().unbindRoutingKey(callback.routingKeyName).then((dynamic d){
        _completer.complete(user);
      });
    }

    if(deviceID!=null){
      callback = RoutingKeyCallback();
      callback.routingKeyName = "mobile.user.${deviceID}";
      callback.callbackFunction = callbackFunction;

      MessageClient().bindRoutingKey(callback).then((dynamic d){
        MessageClient().publishMessage(
            object,
            "mobile.user.update"
        );
      });
    }
    else{
      _completer.complete();
    }

    return _completer.future;
  }

  User fromMap(Map<String,Object> map){
    return User(
        UserID: map["userID"] as String,
        UserStatusID: int.parse(map["userStatusID"].toString()));
  }

  @override
  void bind(Function callbackFnc) {
    // TODO: implement bind
  }
}

