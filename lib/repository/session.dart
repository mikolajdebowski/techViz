import 'dart:async';

import 'package:dart_amqp/dart_amqp.dart';
import 'package:event_bus/event_bus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techviz/config.dart';
import 'package:techviz/model/user.dart';
import 'package:techviz/repository/rabbitmq/channel/userChannel.dart';

class Session {
  User user;
  EventBus eventBus;
  Client _rabbitmqClient;

  static final Session _singleton = Session._internal();
  factory Session() {
    return _singleton;
  }

  Session._internal() {
    print('Session instance');
  }


  Future<Client> get rabbitmqClient async{
    if(_rabbitmqClient==null){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String host = prefs.getString(Config.SERVERURL);
      Uri hostURI =  Uri.parse(host);

      ConnectionSettings settings = ConnectionSettings(host: hostURI.host, authProvider: AmqPlainAuthenticator("test", "test"));
      _rabbitmqClient = Client(settings: settings);
      _rabbitmqClient.errorListener((Object onData) {
        print(onData);
      }, onError: (Object data){
        print('unknown connection error');
      });
    }
    await _rabbitmqClient.connect();
    return _rabbitmqClient;
  }

  void clear(){
    Session session = Session();
    var toSend = {'userStatusID': 10, 'userID': session.user.UserID};
    //todo: hardcoded off-shift id

    UserChannel userChannel = UserChannel();
    userChannel.submit(toSend);

    user = null;
  }

}
