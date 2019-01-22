import 'dart:async';

import 'package:dart_amqp/dart_amqp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techviz/config.dart';
import 'package:techviz/model/user.dart';
import 'package:techviz/repository/async/messageClient.dart';
import 'package:techviz/repository/local/userTable.dart';
import 'package:techviz/repository/async/userMessage.dart';
import 'package:observable/observable.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

enum ConnectionStatus{
  Offline,
  Online,
  Connecting,
  Errored
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
    //print('Session instance');
  }

  void init(String userID) async {
    user = await UserTable.getUser(userID);
    user.changes.listen((List<ChangeRecord> changes) {
      print('changes from User: ');
      print(changes[0]);

      notifyChange(changes[0]);
    });
  }

  Future initRabbitMQ() async{
    Completer _completer = Completer<void>();
    print('initRabbitMQ');
    DeviceInfo deviceInfo = await Utils.deviceInfo;

    MessageClient().init(deviceInfo.DeviceID).then((dynamic d) {
      MessageClient().listen();

      _completer.complete();
    });

    return _completer.future;
  }

  Future<Client> get rabbitmqClient async{

    Completer<Client> _completer = Completer<Client>();

    if(_rabbitmqClient==null){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String host = prefs.getString(Config.SERVERURL);
      Uri hostURI =  Uri.parse(host);

      ConnectionSettings settings = ConnectionSettings(host: hostURI.host, authProvider: AmqPlainAuthenticator("mobile", "mobile"));
      settings.maxConnectionAttempts = 1;

      _rabbitmqClient = Client(settings: settings);
      _rabbitmqClient.errorListener((Exception error){
        print('onData error: ' + error.toString());
      });
    }

    _rabbitmqClient.connect().then((dynamic client){
      print('RabbitMQ connected');

      Session().UpdateConnectionStatus(ConnectionStatus.Online);
      return _completer.complete(_rabbitmqClient);
    }).catchError((dynamic e){
      Session().UpdateConnectionStatus(ConnectionStatus.Errored);
      return _completer.completeError(e);
    });

    return _completer.future;
  }

  void ResetRabbitmqClient(){
    this._rabbitmqClient = null;
  }

  void logOut(){
    Session session = Session();

    UserTable.updateStatusID(session.user.UserID, "10").then((User user){
      session.user = user;
      return Utils.deviceInfo;
    }).then((DeviceInfo deviceInfo){
      var toSend = {'userStatusID': session.user.UserStatusID, 'userID': session.user.UserID};
      return UserMessage().publishMessage(toSend, deviceID: deviceInfo.DeviceID, noWait: true);
    }).then((User user){
      return ;
    });
  }

  void UpdateConnectionStatus(ConnectionStatus newStatus){
    ConnectionStatus oldVakue = connectionStatus;
    connectionStatus = newStatus;

    notifyPropertyChange(#connectionStatus, oldVakue, newStatus);
  }

  void disconnectRabbitmq() async{
    UpdateConnectionStatus(ConnectionStatus.Offline);

    if(_rabbitmqClient!=null){
      await _rabbitmqClient.close().then((dynamic d){
        print('_rabbitmqClient closed');
        _rabbitmqClient = null;
      });
    }
  }

}
