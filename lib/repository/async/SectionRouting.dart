import 'dart:async';
import 'package:techviz/model/section.dart';
import 'package:techviz/repository/async/MessageClient.dart';

abstract class ISectionRouting{
  Future PublishMessage(dynamic object);
  void ListenQueue(Function callback, {Function callbackError});
}

class SectionRouting implements ISectionRouting {
  String routingPattern = "mobile.section";

  @override
  void ListenQueue(Function callback, {Function callbackError}) {
    MessageClient().ListenQueue(routingPattern, callback, onError: callbackError);
  }

  @override
  Future PublishMessage(dynamic message) {
    return MessageClient().PublishMessage(message, routingPattern, parser: parser, wait: true);
  }

  List<Section> parser(dynamic json){
    List<dynamic> sectionsStr = json['sections'] as List<dynamic>;

    List<Section> listToReturn = <Section>[];
    sectionsStr.forEach((dynamic s){
      listToReturn.add(Section(s as String));
    });

    return listToReturn;
  }
}