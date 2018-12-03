import 'package:observable/observable.dart';

class User extends PropertyChangeNotifier {
  String UserID;
  String UserName;
  int UserRoleID;
  int UserStatusID;

  User({this.UserID, this.UserName, this.UserRoleID, this.UserStatusID});

  User.fromMap(Map map){
    UserID = map['UserID'] as String;
    UserRoleID = int.parse(map['UserRoleID'].toString());
    UserStatusID = int.parse(map['UserStatusID'].toString());
  }
}