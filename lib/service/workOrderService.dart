import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:techviz/common/deviceUtils.dart';
import 'package:techviz/common/model/deviceInfo.dart';

import 'client/MQTTClientService.dart';

abstract class IWorkOrderService{
  Future create(String userID, int taskTypeID, {String location, String mNumber, String notes, DateTime dueDate});
}

class WorkOrderService implements IWorkOrderService{
  static final WorkOrderService _instance = WorkOrderService._internal();

  factory WorkOrderService({IMQTTClientService mqttClientService, IDeviceUtils deviceUtils}) {
    _instance._mqttClientServiceInstance = mqttClientService ??= MQTTClientService();
    _instance._deviceUtils = deviceUtils ?? DeviceUtils();
    assert(_instance._mqttClientServiceInstance!=null);
    return _instance;
  }
  WorkOrderService._internal();

  IMQTTClientService _mqttClientServiceInstance;
  IDeviceUtils _deviceUtils;

  @override
  Future create(String userID, int taskTypeID, {String location, String mNumber, String notes, DateTime dueDate})async{
    assert(userID!=null);

    DeviceInfo deviceInfo = _deviceUtils.deviceInfo;

    Completer _completer = Completer<List<String>>();
    String routingKeyForPublish = 'mobile.workorder.update';
    String routingKeyForCallback = 'mobile.workorder.update.${deviceInfo.DeviceID}';

    _mqttClientServiceInstance.subscribe(routingKeyForCallback);
    _mqttClientServiceInstance.streams(routingKeyForCallback).listen((dynamic responseCallback) async{
      _mqttClientServiceInstance.unsubscribe(routingKeyForCallback);

      dynamic jsonWorkOrderResult = json.decode(responseCallback);
      int validmachine = jsonWorkOrderResult['validmachine'] as int;
      if(validmachine==0){
        _completer.completeError('Invalid Location/Asset Number');
        return;
      }
      _completer.complete();
    });

    Map<String, dynamic> payload = <String, dynamic>{};
    payload['userID'] = userID;
    payload['workOrderStatusID'] = 0; //CREATING
    payload['location'] = location;
    payload['taskTypeID'] = taskTypeID;
    payload['mNum'] = mNumber;
    payload['deviceID'] = deviceInfo.DeviceID;

    payload['notes'] = notes;
    payload['dueDate'] = dueDate!=null? DateFormat("yyyy-MM-dd").format(dueDate) : null;

    _mqttClientServiceInstance.publishMessage(routingKeyForPublish, payload);
    return _completer.future.timeout(Duration(seconds: 10));
  }

}

