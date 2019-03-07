import 'package:observable/observable.dart';

class User extends PropertyChangeNotifier {
  String UserID;
  String UserName;
  int UserRoleID;
  int UserStatusID;
  String StaffID;

  User({this.UserID, this.UserName, this.UserRoleID, this.UserStatusID, this.StaffID});

  User.fromMap(Map map){
    UserID = map['UserID'] as String;
    UserRoleID = int.parse(map['UserRoleID'].toString());
    UserStatusID = int.parse(map['UserStatusID'].toString());
    UserName = map['UserName'] as String;
    StaffID = map['StaffID'] as String;
  }
}