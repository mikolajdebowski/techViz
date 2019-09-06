import 'dart:async';
import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:techviz/common/deviceUtils.dart';
import 'package:techviz/common/model/deviceInfo.dart';
import 'package:techviz/model/slotMachine.dart';
import 'package:synchronized/synchronized.dart';
import 'client/MQTTClientService.dart';

abstract class ISlotFloorService{
  Stream<List<SlotMachine>> get machineStatus;
  Future<void> setReservation(String standID, String userID, {String playerID, int time});
  Future<void> cancelReservation(String standID);
  void listenAsync();
  void cancelListening();
  void dispose();
}

class SlotFloorService implements ISlotFloorService{
  static final SlotFloorService _instance = SlotFloorService._internal();
  factory SlotFloorService({IMQTTClientService mqttClientService, IDeviceUtils deviceUtils}) {
    _instance._mqttClientServiceInstance = mqttClientService ??= MQTTClientService();
    _instance._deviceUtils = deviceUtils ?? DeviceUtils();
    assert(_instance._mqttClientServiceInstance!=null);
    return _instance;
  }
  SlotFloorService._internal();

  IMQTTClientService _mqttClientServiceInstance;
  IDeviceUtils _deviceUtils;
  final BehaviorSubject<List<SlotMachine>> _machineStatusSubject = BehaviorSubject<List<SlotMachine>>();
  Stream<dynamic> _localStream;
  List<SlotMachine> _slotMachines = [];
  final _lock = Lock();

  @override
  Stream<List<SlotMachine>> get machineStatus => _machineStatusSubject.stream;

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

    await _manageReservation(message);

    await _lock.synchronized(() async {
      int idx = _slotMachines.indexWhere((SlotMachine slotMachine)=>slotMachine.standID == standID);
      if(idx<0)
        return;

      _slotMachines[idx].dirty = true;
      _machineStatusSubject.add(_slotMachines);
    });
  }

  @override
  Future<void> cancelReservation(String standID) async {
    assert(standID != null);

    Map<String,dynamic> message = <String,dynamic>{};

    message['standId'] = standID;
    message['reservationStatusId'] = 1;
    await _manageReservation(message);

    await _lock.synchronized(() async {
      int idx = _slotMachines.indexWhere((SlotMachine slotMachine)=>slotMachine.standID == standID);
      if(idx<0)
        return;

      _slotMachines[idx].dirty = true;
      _machineStatusSubject.add(_slotMachines);
    });
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
    _localStream.listen((dynamic payload) async{
      List<SlotMachine> slotMachineList = [];

      dynamic jsonPayload = jsonDecode(payload);

      String startedAt = jsonPayload['startedAt'] as String;
      List<dynamic> data = jsonPayload['data'] as List<dynamic>;
      data.forEach((dynamic entry){
        entry['startedAt'] = startedAt;
        slotMachineList.add(_parser(entry));
      });

      await _lock.synchronized(() async {
        _slotMachines = slotMachineList;
      });

      _machineStatusSubject.add(_slotMachines);
    });
  }

  SlotMachine _parser(dynamic json){
    return SlotMachine(
        dirty: false,
        standID: json['standId'].toString(),
        denom: double.parse(json['denom'].toString()),
        machineTypeName: json['machineTypeName'].toString(),
        machineStatusID:  json['statusId'].toString(),
        machineStatusDescription: json['statusDescription'].toString(),
        updatedAt: DateTime.parse(json['startedAt'].toString())
    );
  }
}

