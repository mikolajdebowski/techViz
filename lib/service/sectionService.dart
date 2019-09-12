import 'dart:async';
import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:techviz/common/deviceUtils.dart';
import 'package:techviz/common/model/deviceInfo.dart';
import 'package:techviz/service/Service.dart';
import 'client/MQTTClientService.dart';

abstract class ISectionService{
  Future<List<String>> update(String userID, List<String> sections);
  void listenAsync();
  void cancelListening();
  void dispose();
}

class SectionService extends Service implements ISectionService{
  static final SectionService _instance = SectionService._internal();
  factory SectionService({IMQTTClientService mqttClientService, IDeviceUtils deviceUtils}) {
    _instance._mqttClientServiceInstance = mqttClientService ??= MQTTClientService();
    _instance._deviceUtils = deviceUtils ?? DeviceUtils();
    assert(_instance._mqttClientServiceInstance!=null);
    return _instance;
  }
  SectionService._internal();

  IMQTTClientService _mqttClientServiceInstance;
  IDeviceUtils _deviceUtils;
  final BehaviorSubject<List<String>> _userSectionsListSubject = BehaviorSubject<List<String>>();
  Stream<dynamic> _localStream;
  Stream<List<String>> get userSectionsList => _userSectionsListSubject.stream;

  @override
  Future<List<String>> update(String userID, List<String> sections) async{
    assert(userID!=null);

    DeviceInfo deviceInfo = _deviceUtils.deviceInfo;

    Completer _completer = Completer<List<String>>();
    String routingKeyForPublish = 'mobile.section.update';
    String routingKeyForCallback = 'mobile.section.update.${deviceInfo.DeviceID}';

    _mqttClientServiceInstance.subscribe(routingKeyForCallback);
    _mqttClientServiceInstance.streams(routingKeyForCallback).listen((dynamic responseCallback) async{
      _mqttClientServiceInstance.unsubscribe(routingKeyForCallback);
      _completer.complete(sections);
    });

    Map<String,dynamic> message = <String,dynamic>{};
    message['deviceID'] = deviceInfo.DeviceID;
    message['userID'] = userID;
    message['sections'] = sections;

    _mqttClientServiceInstance.publishMessage(routingKeyForPublish, message);


    return _completer.future.timeout(Service.defaultTimeoutForServices).catchError((dynamic error){
      if(error is TimeoutException){
        throw Exception("Mobile device has not received a response and has time out after ${Service.defaultTimeoutForServices.inSeconds.toString()} seconds. Please check network details and try again.");
      }
    });
  }

  @override
  void cancelListening() {
    String deviceID = _deviceUtils.deviceInfo.DeviceID;
    _mqttClientServiceInstance.unsubscribe('mobile.sectionlist.$deviceID');
  }

  @override
  void dispose() {
    _userSectionsListSubject?.close();
  }

  @override
  void listenAsync() {
    String deviceID = _deviceUtils.deviceInfo.DeviceID;
    _localStream = _mqttClientServiceInstance.subscribe('mobile.sectionlist.$deviceID');
    _localStream.listen((dynamic data){
      dynamic json = JsonDecoder().convert(data);

      if(json['SectionList'] == null)
        return _userSectionsListSubject.add([]);

      List<String> sectionList = json['SectionList'].toString().split(',');
      if(sectionList.isEmpty)
        return _userSectionsListSubject.add([]);

      _userSectionsListSubject.add(sectionList.map((String s)=>s.trim()).toList());
    });
  }
}

