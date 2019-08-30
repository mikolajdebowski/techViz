import 'dart:async';
import 'package:techviz/model/role.dart';
import 'package:techviz/model/user.dart';
import 'package:observable/observable.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/service/client/MQTTClientService.dart';
import 'package:techviz/service/userService.dart';

enum ConnectionStatus{
  Offline,
  Online,
  Connecting,
  Errored
}

abstract class ISession{
  User get user;
  Role get role;
  ConnectionStatus get connectionStatus;
  Future init(String userID);
  Future logOut();
  void UpdateConnectionStatus(ConnectionStatus newStatus);
}

class Session extends PropertyChangeNotifier implements ISession{
  @override
  User user;

  @override
  Role role;

  @override
  ConnectionStatus connectionStatus;

  static final Session _singleton = Session._internal();
  factory Session() {
    return _singleton;
  }

  Session._internal();

  @override
  Future init(String userID) async {
    user = await Repository().userRepository.getUser(userID);
    role = (await Repository().roleRepository.getAll(ids: [user.userRoleID.toString()])).first;

    user.changes.listen((List<ChangeRecord> changes) {
      print('changes from User: ');
      print(changes[0]);
      notifyChange(changes[0]);
    });
  }

  @override
  Future logOut() async  {

    Repository().stopServices();
    Repository().disposeBlocs();

    UserService userService = UserService();
    await userService.update(user.userID, statusID: 10);

    MQTTClientService().disconnect();
  }

  @override
  void UpdateConnectionStatus(ConnectionStatus newStatus){
    ConnectionStatus oldValue = connectionStatus;
    connectionStatus = newStatus;

    print('Connection status changed: $oldValue to $newStatus');

    notifyPropertyChange(#connectionStatus, oldValue, newStatus);
  }
}
