import 'dart:async';
import 'package:techviz/model/role.dart';
import 'package:techviz/model/user.dart';
import 'package:observable/observable.dart';
import 'package:techviz/model/userSection.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/service/client/MQTTClientService.dart';
import 'package:techviz/service/taskService.dart';
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
  List<String> sections;
}

class Session extends PropertyChangeNotifier implements ISession{
  @override
  User user;

  @override
  Role role;

  @override
  List<String> sections;

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
    sections = (await Repository().userSectionRepository.getUserSections(userID)).map((UserSection us)=>us.sectionID).toList();

    user.changes.listen((List<ChangeRecord> changes) {
      print('changes from User: ');
      print(changes[0]);
      notifyChange(changes[0]);
    });
  }

  @override
  Future logOut() async  {

    UserService userService = UserService();
    await userService.update(user.userID, statusID: 10);

    TaskService().cancelListening();
    UserService().cancelListening();

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
