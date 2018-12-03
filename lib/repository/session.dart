import 'dart:async';

import 'package:dart_amqp/dart_amqp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techviz/config.dart';
import 'package:techviz/model/user.dart';
import 'package:techviz/repository/local/userTable.dart';
import 'package:techviz/repository/rabbitmq/channel/userChannel.dart';
import 'package:observable/observable.dart';

enum ConnectionStatus{
  Offline,
  Online,
  Connecting
}

class Session extends PropertyChangeNotifier {
  User user;
  Client _rabbitmqClient;
  ConnectionStatus connectionStatus;

  static final Session _singleton = Session._internal();
  factory Session() {
    return _singleton;
  }

  Session._internal() {
    print('Session instance');
  }

  void init(String userID) async {
    user = await UserTable.getUser(userID);
    user.changes.listen((List<ChangeRecord> changes) {
      print('changes from User: ');
      print(changes[0]);

      notifyChange(changes[0]);
    });
  }

  Future<Client> get rabbitmqClient async{
    if(_rabbitmqClient==null){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String host = prefs.getString(Config.SERVERURL);
      Uri hostURI =  Uri.parse(host);

      ConnectionSettings settings = ConnectionSettings(host: hostURI.host, authProvider: AmqPlainAuthenticator("test", "test"));
      settings.maxConnectionAttempts = 1;

      _rabbitmqClient = Client(settings: settings);
      _rabbitmqClient.errorListener((Exception error){
        print('onData error: ' + error.toString());
      });
    }
    await _rabbitmqClient.connect();
    Session().UpdateConnectionStatus(ConnectionStatus.Online);

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

  void UpdateConnectionStatus(ConnectionStatus newStatus){
    ConnectionStatus oldVakue = connectionStatus;
    connectionStatus = newStatus;

    notifyPropertyChange(#connectionStatus, oldVakue, newStatus);
  }

  void disconnectRabbitmq(){
    UpdateConnectionStatus(ConnectionStatus.Offline);

    if(_rabbitmqClient!=null){
      _rabbitmqClient.close().then((dynamic d){
        print('_rabbitmqClient closed');
        _rabbitmqClient = null;
      });
    }
  }

}
