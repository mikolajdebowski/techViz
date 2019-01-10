import 'dart:async';
import 'package:techviz/repository/async/messageClient.dart';
import 'package:techviz/model/user.dart';

class UserMessage implements IMessageClient<dynamic,User> {
  RoutingKeyCallback callback;

  @override
  Future<User> publishMessage(dynamic object, {String deviceID, bool noWait = false}) async{
    print('publishMessage starts ${this.hashCode}');

    Completer<User> _completer = Completer();
    void callbackFunction(Map<String, dynamic> map){
      print('callbackFunction called ${this.hashCode}');
      User user = fromMap(map);

      MessageClient().unbindRoutingKey(callback.routingKeyName).then((dynamic d){
        _completer.complete(user);
      });
    }

    void _publishMesssage(){
      print('publishing message ${this.hashCode}');
      MessageClient().publishMessage(
          object,
          "mobile.user.update"
      );
    }

    if(noWait){
      _publishMesssage();
    }
    else{
      callback = RoutingKeyCallback();
      callback.routingKeyName = "mobile.user.${deviceID}";
      callback.callbackFunction = callbackFunction;

      MessageClient client = MessageClient();
      client.bindRoutingKey(callback).then((dynamic d){
        print('binded to routingKey ${this.hashCode}');
        _publishMesssage();
      });
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

