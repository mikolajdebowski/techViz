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
    return User(
        userID: json["userID"] as String,
        userStatusID: int.parse(json["userStatusID"].toString()));
  }


}