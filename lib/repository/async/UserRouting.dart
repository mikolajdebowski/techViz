import 'dart:async';
import 'package:techviz/model/user.dart';
import 'package:techviz/repository/async/MessageClient.dart';

class UserRouting {
  String routingPattern = "mobile.user";

  void ListenQueue(Function callback, {Function callbackError}) {
    throw UnimplementedError();
  }

  Future PublishMessage(dynamic message) {
    return MessageClient().PublishMessage(message, routingPattern, parser: parser, wait: true);
  }

  User parser(dynamic json){
    String userID = json["userID"];
    int statusID = json["userStatusID"] != null?int.parse(json["userStatusID"].toString()):0;
    int roleID = json["userRoleID"] != null?int.parse(json["userRoleID"].toString()):0;

    return User(
        userID: userID,
        userStatusID: statusID,
        userRoleID: roleID);
  }
}