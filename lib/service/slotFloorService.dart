import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:techviz/common/deviceUtils.dart';
import 'package:techviz/common/model/deviceInfo.dart';
import 'package:techviz/model/slotMachine.dart';
import 'package:synchronized/synchronized.dart';
import 'client/MQTTClientService.dart';

abstract class ISlotMachineService{
  Future<void> setReservation(String standID, String userID, {String playerID, int time});
  Future<void> cancelReservation(String standID);
  void listenAsync();
  void cancelListening();
  void dispose();
}

class SlotMachineService implements ISlotMachineService{
  static final SlotMachineService _instance = SlotMachineService._internal();
  factory SlotMachineService({IMQTTClientService mqttClientService, IDeviceUtils deviceUtils}) {
    _instance._mqttClientServiceInstance = mqttClientService ??= MQTTClientService();
    _instance._deviceUtils = deviceUtils ?? DeviceUtils();
    assert(_instance._mqttClientServiceInstance!=null);
    return _instance;
  }
  SlotMachineService._internal();

  IMQTTClientService _mqttClientServiceInstance;
  IDeviceUtils _deviceUtils;
  final BehaviorSubject<List<SlotMachine>> _machineStatusSubject = BehaviorSubject<List<SlotMachine>>();
  Stream<dynamic> _localStream;
  Stream<List<SlotMachine>> get machineStatus => _machineStatusSubject.stream;
  final List<SlotMachine> _slotMachines = [];
  final _lock = Lock();

  @override
  Future<void> setReservation(String standID, String userID, {String playerID, int time}) async{
    assert(standID!=null);
    assert(userID!=null);

    Map<String,dynamic> message = <String,dynamic>{};

    message['standId'] = standID;
    message['userId'] = userID;
    if(playerID!=null){
      message['playerId'] = playerID;
    }
    if(time!=null){
      message['reservationTimeId'] = time;
    }
    message['reservationStatusId'] = 0;

    return _manageReservation(message);
  }

  @override
  Future<void> cancelReservation(String standID) async {
    assert(standID != null);

    Map<String,dynamic> message = <String,dynamic>{};

    message['standId'] = standID;
    message['reservationStatusId'] = 1;
    return _manageReservation(message);
  }

  Future<void> _manageReservation(Map payload){
    DeviceInfo deviceInfo = _deviceUtils.deviceInfo;

    Completer _completer = Completer<List<String>>();
    String routingKeyForPublish = 'mobile.reservation.update';
    String routingKeyForCallback = 'mobile.reservation.update.${deviceInfo.DeviceID}';

    _mqttClientServiceInstance.subscribe(routingKeyForCallback);
    _mqttClientServiceInstance.streams(routingKeyForCallback).listen((dynamic responseCallback) async{
      _mqttClientServiceInstance.unsubscribe(routingKeyForCallback);
      _completer.complete();
    });

    payload['deviceId'] = deviceInfo.DeviceID;
    payload['siteId'] = 1;

    _mqttClientServiceInstance.publishMessage(routingKeyForPublish, payload);

    return _completer.future.timeout(Duration(seconds: 10));
  }

  @override
  void cancelListening() {
    _mqttClientServiceInstance.unsubscribe('mobile.machineStatus');
  }

  @override
  void dispose() {
    _machineStatusSubject?.close();
  }

  @override
  void listenAsync() {
    _localStream = _mqttClientServiceInstance.subscribe('mobile.machineStatus');
    _localStream.listen((dynamic data){
        print(data);
    });
  }
}

