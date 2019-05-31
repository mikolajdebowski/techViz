import 'dart:async';
import 'package:techviz/model/user.dart';
import 'package:techviz/repository/async/MessageClient.dart';

abstract class IUserRouting{
  void listenQueue(Function callback, {Function callbackError});
  Future publishMessage(dynamic message);
  User parser(dynamic json);
}

class UserRouting implements IUserRouting {
  String routingPattern = "mobile.user";
  IMessageClient iMessageClient;

  UserRouting(this.iMessageClient);

  @override
  void listenQueue(Function callback, {Function callbackError}) {
    throw UnimplementedError();
  }

  @override
  Future publishMessage(dynamic message) {
    return iMessageClient.PublishMessage(message, routingPattern, parser: parser, wait: true);
  }

  @override
  User parser(dynamic json){
    Map<String,dynamic> map = <String,dynamic>{};
    map['UserID'] = json["userID"];
    map['userRoleID'] = json["userRoleID"] != null?int.parse(json["userRoleID"].toString()) : 0;
    map['userStatusID'] = json["userStatusID"] != null?int.parse(json["userStatusID"].toString()) : 0;
    return User.fromMap(map);
  }
}