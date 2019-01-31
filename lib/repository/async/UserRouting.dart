import 'dart:async';
import 'package:techviz/model/user.dart';
import 'package:techviz/repository/async/IRouting.dart';
import 'package:techviz/repository/async/Routing.dart';

class UserRouting implements IRouting {
  String routingPattern = "mobile.user";

  @override
  void ListenQueue(Function callback, {Function callbackError}) {
    Routing().ListenQueue(routingPattern, callback, callbackError: callbackError);
  }

  @override
  Future PublishMessage(dynamic message, {Function callback, Function callbackError}) {
    return Routing().PublishMessage(routingPattern, message, callback: callback, callbackError: callbackError, parser: parser);
  }

  User parser(dynamic json){
    return User(
        UserID: json["userID"] as String,
        UserStatusID: int.parse(json["userStatusID"].toString()));
  }


}