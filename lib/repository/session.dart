import 'dart:async';

import 'package:dart_amqp/dart_amqp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techviz/config.dart';
import 'package:techviz/model/user.dart';
import 'package:techviz/repository/local/userTable.dart';
import 'package:techviz/repository/rabbitmq/channel/userChannel.dart';

class Session {
  User user;
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
    _rabbitmqClient.connect();
    return _rabbitmqClient;
  }

  Future<dynamic> logOut() async{
    Session session = Session();


    if(session.user.UserStatusID!=0 && session.user.UserStatusID != 10){

      session.user = await UserTable.updateStatusID(session.user.UserID, "10");
    }
    var toSend = {'userStatusID': session.user.UserStatusID, 'userID': session.user.UserID};
    //todo: hardcoded off-shift id

    UserChannel userChannel = UserChannel();
    return userChannel.submit(toSend);
  }

  void disconnectRabbitmq(){
    if(_rabbitmqClient!=null){
      _rabbitmqClient.close().then((dynamic d){
        print('_rabbitmqClient closed');
        _rabbitmqClient = null;
      });
    }
  }

}
