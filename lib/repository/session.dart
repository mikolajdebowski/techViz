import 'dart:async';
import 'package:techviz/model/role.dart';
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
  Role role;
  ConnectionStatus connectionStatus;

  static final Session _singleton = Session._internal();
  factory Session() {
    return _singleton;
  }

  Session._internal();

  Future init(String userID) async {
    user = await UserTable.getUser(userID);

    user.changes.listen((List<ChangeRecord> changes) {
      print('changes from User: ');
      print(changes[0]);

      notifyChange(changes[0]);
    });
  }

  Future logOut() async  {
    DeviceInfo info = await Utils.deviceInfo;

    Session session = Session();

    var toSend = {'userStatusID': '10', 'userID': session.user.userID, 'deviceID': info.DeviceID};
    await UserRouting().PublishMessage(toSend);
  }

  void UpdateConnectionStatus(ConnectionStatus newStatus){
    ConnectionStatus oldValue = connectionStatus;
    connectionStatus = newStatus;

    print('Connection status changed: ${oldValue} to ${newStatus}');

    notifyPropertyChange(#connectionStatus, oldValue, newStatus);
  }
}
