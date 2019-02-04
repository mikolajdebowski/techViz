import 'dart:async';
import 'package:techviz/model/user.dart';
import 'package:techviz/repository/async/IRouting.dart';
import 'package:techviz/repository/async/MessageClient.dart';

class UserRouting implements IRouting {
  String routingPattern = "mobile.user";

  @override
  void ListenQueue(Function callback, {Function callbackError}) {
    MessageClient().ListenQueue(routingPattern, callback, onError: callbackError);
  }

  @override
  Future PublishMessage(dynamic message, {Function callback, Function callbackError}) {
    return MessageClient().PublishMessage(message, routingPattern, callback: callback, callbackError: callbackError, parser: parser);
  }

  User parser(dynamic json){
    return User(
        UserID: json["userID"] as String,
        UserStatusID: int.parse(json["userStatusID"].toString()));
  }


}