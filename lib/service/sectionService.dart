import 'dart:async';
import 'package:techviz/common/deviceUtils.dart';
import 'package:techviz/repository/repository.dart';
import 'client/MQTTClientService.dart';

abstract class ISectionService{
  Future<List<String>> update(String userID, List<String> sections, String deviceID);
}

class SectionService implements ISectionService{
  IMQTTClientService _mqttClientServiceInstance;
  Repository _repositoryInstance;

  SectionService({IMQTTClientService mqttClientService, IDeviceUtils deviceUtils, Repository repository}){
    _mqttClientServiceInstance = mqttClientService!=null? mqttClientService : MQTTClientService();
    _repositoryInstance = repository ??= Repository();
    assert(_mqttClientServiceInstance!=null);
    assert(_repositoryInstance!=null);
  }

  @override
  Future<List<String>> update(String userID, List<String> sections, String deviceID) async{
    assert(userID!=null);

    Completer _completer = Completer<List<String>>();
    String routingKeyForPublish = 'mobile.section.update';
    String routingKeyForCallback = 'mobile.section.update.$deviceID';

    _mqttClientServiceInstance.subscribe(routingKeyForCallback);
    _mqttClientServiceInstance.streams(routingKeyForCallback).listen((dynamic responseCallback) async{
      _mqttClientServiceInstance.unsubscribe(routingKeyForCallback);
      _completer.complete(sections);
    });

    Map<String,dynamic> message = <String,dynamic>{};
    message['deviceID'] = deviceID;
    message['userID'] = userID;
    message['sections'] = sections;

    _mqttClientServiceInstance.publishMessage(routingKeyForPublish, message);


    return _completer.future.timeout(Duration(seconds: 10));
  }
}

