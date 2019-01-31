import 'dart:async';
import 'package:techviz/model/section.dart';
import 'package:techviz/model/user.dart';
import 'package:techviz/repository/async/IRouting.dart';
import 'package:techviz/repository/async/Routing.dart';

class SectionRouting implements IRouting {
  String routingPattern = "mobile.section";

  @override
  void ListenQueue(Function callback, {Function callbackError}) {
    Routing().ListenQueue(routingPattern, callback, callbackError: callbackError);
  }

  @override
  Future PublishMessage(dynamic message, {Function callback, Function callbackError}) {
    return Routing().PublishMessage(routingPattern, message, callback: callback, callbackError: callbackError, parser: parser);
  }

  List<Section> parser(dynamic json){
    List<dynamic> sectionsStr = json['sections'];

    List<Section> listToReturn = List<Section>();
    sectionsStr.forEach((dynamic s){
      listToReturn.add(Section(s as String));
    });

    return listToReturn;
  }
}