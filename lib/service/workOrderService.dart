import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:techviz/common/deviceUtils.dart';
import 'package:techviz/common/model/deviceInfo.dart';
import 'client/MQTTClientService.dart';

abstract class IWorkOrderService{
  Future create(String userID, int taskTypeID, {String location, String mNumber, String notes, DateTime dueDate});
//  void listenAsync();
//  void cancelListening();
//  void dispose();
}

class WorkOrderService implements IWorkOrderService{
  static final WorkOrderService _instance = WorkOrderService._internal();

  factory WorkOrderService({IMQTTClientService mqttClientService}) {
    _instance._mqttClientServiceInstance = mqttClientService ??= MQTTClientService();
    assert(_instance._mqttClientServiceInstance!=null);
    return _instance;
  }
  WorkOrderService._internal();

  IMQTTClientService _mqttClientServiceInstance;
//  final BehaviorSubject<List<String>> _userSectionsListSubject = BehaviorSubject<List<String>>();
//  Stream<dynamic> _localStream;
//  Stream<List<String>> get userSectionsList => _userSectionsListSubject.stream;

  @override
  Future create(String userID, int taskTypeID, {String location, String mNumber, String notes, DateTime dueDate})async{
    assert(userID!=null);

    Completer _completer = Completer<List<String>>();
    String routingKeyForPublish = 'mobile.workorder';


    Map<String, dynamic> payload = <String, dynamic>{};
    payload['userID'] = userID;
    payload['workOrderStatusID'] = 0; //CREATING
    payload['location'] = location;
    payload['taskTypeID'] = taskTypeID;
    payload['mNum'] = mNumber;

    payload['notes'] = notes;
    payload['dueDate'] = dueDate!=null? DateFormat("yyyy-MM-dd").format(dueDate) : null;

    _mqttClientServiceInstance.publishMessage(routingKeyForPublish, payload);
    return _completer.future.timeout(Duration(seconds: 10));
  }


//  @override
//  void cancelListening() {
//    String deviceID = _deviceUtils.deviceInfo.DeviceID;
//    _mqttClientServiceInstance.unsubscribe('mobile.sectionlist.$deviceID');
//  }
//
//  @override
//  void dispose() {
//    _userSectionsListSubject?.close();
//  }
//
//  @override
//  void listenAsync() {
//    String deviceID = _deviceUtils.deviceInfo.DeviceID;
//    _localStream = _mqttClientServiceInstance.subscribe('mobile.sectionlist.$deviceID');
//    _localStream.listen((dynamic data){
//      dynamic json = JsonDecoder().convert(data);
//
//      if(json['SectionList'] == null)
//        return _userSectionsListSubject.add([]);
//
//      List<String> sectionList = json['SectionList'].toString().split(',');
//      if(sectionList.isEmpty)
//        return _userSectionsListSubject.add([]);
//
//      _userSectionsListSubject.add(sectionList.map((String s)=>s.trim()).toList());
//    });
//  }
}

