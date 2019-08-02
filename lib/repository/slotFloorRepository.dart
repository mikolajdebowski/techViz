import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:techviz/model/slotMachine.dart';
import 'package:synchronized/synchronized.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';
import 'async/SlotMachineRouting.dart';

abstract class ISlotFloorRemoteRepository {
  Future<List<Map>> fetch();
  Future<List<Map>> slotFloorSummary();
}

class SlotFloorRepository {
  ISlotFloorRemoteRepository remoteRepository;
  ISlotMachineRouting remoteRouting;

  List<SlotMachine> _cachedLocalData = [];
  ReplaySubject<List<SlotMachine>> _slotMachineReplaySubject;
  StreamController<List<SlotMachine>> _slotMachineRemoteStreamController;


  SlotFloorRepository(this.remoteRepository, this.remoteRouting) {
    _slotMachineReplaySubject = ReplaySubject<List<SlotMachine>>();
  }

  ReplaySubject<List<SlotMachine>> get slotMachineSubject{
    return _slotMachineReplaySubject;
  }

  Future fetch() {
    assert(remoteRepository != null);
    Completer _completer = Completer<void>();
    remoteRepository.fetch().then((List<Map> data) {

      SlotMachine parser(Map<dynamic,dynamic> map){
        return SlotMachine(
          standID: map['StandID'].toString(),
          machineTypeName: map['MachineTypeName'].toString(),
          machineStatusID: map['StatusID'].toString(),
          machineStatusDescription: map['StatusDescription'].toString(),
          denom: double.parse(map['Denom'].toString()),
          updatedAt: DateTime.now().toUtc(),
        );
      }

      List<SlotMachine> parsed = data.map<SlotMachine>((Map<dynamic,dynamic> map) => parser(map)).toList();
      _cachedLocalData = parsed;
      _slotMachineReplaySubject.add(_cachedLocalData);
      _completer.complete();
    });
    return _completer.future;
  }

  Future<void> _updateLocalDataEntry(SlotMachine received, String from){
    return Lock().synchronized((){
      int idx = _cachedLocalData.indexWhere((SlotMachine _sm) => _sm.standID == received.standID);
      if (idx >= 0) {
        if (received.updatedAt.compareTo(_cachedLocalData[idx].updatedAt) >= 0) {
          _cachedLocalData[idx].machineStatusID = received.machineStatusID;
          _cachedLocalData[idx].updatedAt = received.updatedAt;
          _cachedLocalData[idx].dirty = received.dirty;
          _cachedLocalData[idx].machineTypeName = received.machineTypeName;
          _cachedLocalData[idx].denom = received.denom;
        }
      }
      else{
        _cachedLocalData.add(received);
      }
    });
  }

  void updateLocalCache(List<SlotMachine> received, String from) async {
    Future.forEach(received, (SlotMachine slotMachine) async{
      await _updateLocalDataEntry(slotMachine, from);
    });
    _slotMachineReplaySubject.add(_cachedLocalData);
  }

  void listenAsync() {
    _slotMachineRemoteStreamController = remoteRouting.Listen();
    _slotMachineRemoteStreamController.stream.asBroadcastStream().listen((List<SlotMachine> fromRemote){
      updateLocalCache(fromRemote, 'EVENT');
    });
  }

  void cancelAsync() {
    if(_slotMachineRemoteStreamController!=null && _slotMachineRemoteStreamController.isClosed==false){
      _slotMachineRemoteStreamController.close();
    }
  }

  List<SlotMachine> filter(String key) {
    if (key == null || key.isEmpty)
      return _cachedLocalData;

    Iterable<SlotMachine> it = _cachedLocalData.where((SlotMachine sm) => sm.standID.contains(key));
    if (it != null) {
      return it.toList();
    }
    return [];
  }

  Future setReservation(String userID, String standId, String playerID, String time) async {
    Completer _completer = Completer<void>();

    DeviceInfo info = await Utils.deviceInfo;

    dynamic message = {'deviceId': '${info.DeviceID}', 'userId': '$userID', 'standId': '$standId', 'playerId': '$playerID', 'reservationTimeId': int.parse(time), 'reservationStatusId': 0, 'siteId': 1};

    remoteRouting.PublishMessage(message).then((dynamic result) {
      _completer.complete(result);
    }).catchError((dynamic error){
      _completer.completeError(error);
    });

    return _completer.future;
  }

  Future cancelReservation(String standId) async {
    Completer _completer = Completer<void>();

    DeviceInfo info = await Utils.deviceInfo;

    dynamic message = {'deviceId': '${info.DeviceID}', 'standId': '$standId', 'reservationStatusId': 1, 'siteId': 1};

    remoteRouting.PublishMessage(message).then((dynamic result) {
      _completer.complete(result);
    }).catchError((dynamic error){
      _completer.completeError(error);
    });

    return _completer.future;
  }

  Future<List<SlotMachine>> slotFloorSummary(){
    Completer<List<SlotMachine>> _completer = Completer<List<SlotMachine>>();
    remoteRepository.slotFloorSummary().then((List<Map> result){
      List<SlotMachine> listToReturn = <SlotMachine>[];

      SlotMachine parser(Map<dynamic,dynamic> map){
        return SlotMachine(
          standID: map['StandID'].toString(),
          denom: double.parse( map['Denom'].toString()),
          machineStatusID:  map['StatusID'].toString(),
          machineStatusDescription: map['StatusDescription'].toString(),
          machineTypeName:  map['MachineTypeName'].toString(),
          reservationTime: map['ReservationTime'].toString(),
          playerID: map['PlayerID'].toString(),
        );
      }
      listToReturn = result.map((Map<dynamic,dynamic> map)=> parser(map)).toList();
      _completer.complete(listToReturn);
    }).catchError((dynamic error){
      _completer.completeError(error);
    });

    return _completer.future;
  }
}
