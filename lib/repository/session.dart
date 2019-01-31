import 'dart:async';
import 'package:techviz/model/user.dart';
import 'package:techviz/repository/async/UserRouting.dart';
import 'package:techviz/repository/local/userTable.dart';
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

  Future logOut() async  {
    DeviceInfo info = await Utils.deviceInfo;

    Completer<void> _completer = Completer<void>();
    Session session = Session();

    UserRouting ur = UserRouting();
    var toSend = {'userStatusID': '10', 'userID': session.user.UserID, 'deviceID': info.DeviceID};
    ur.PublishMessage(toSend, callback: (User user){
      UserTable.updateStatusID(session.user.UserID, "10").then((User user) {
        Session().user = user;
        _completer.complete();
      });
    }, callbackError: (dynamic error){
      _completer.completeError(error);
    });

    return _completer.future;
  }

  void UpdateConnectionStatus(ConnectionStatus newStatus){
    ConnectionStatus oldValue = connectionStatus;
    connectionStatus = newStatus;

    print('Connection status changed: ${oldValue} to ${newStatus}');

    notifyPropertyChange(#connectionStatus, oldValue, newStatus);
  }
}
