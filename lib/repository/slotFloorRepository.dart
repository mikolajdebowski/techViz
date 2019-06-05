import 'dart:async';
import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/repository/async/IRouting.dart';
import 'package:techviz/repository/cache/slotMachineCache.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

abstract class ISlotFloorRemoteRepository {
  Future<List<Map>> fetch();
  Future<List<Map>> slotFloorSummary();
}

class SlotFloorRepository {
  ISlotFloorRemoteRepository remoteRepository;
  IRouting<SlotMachine> remoteRouting;

  StreamController<SlotMachine> _slotMachineController;
  StreamController<List<SlotMachine>> _remoteSlotMachineController;
  final SlotMachineCache _cache = SlotMachineCache();

  StreamController<List<SlotMachine>> get remoteSlotMachineController{
    return _remoteSlotMachineController;
  }

  SlotFloorRepository(this.remoteRepository, this.remoteRouting) {
    _remoteSlotMachineController = StreamController<List<SlotMachine>>();
  }

  Future fetch() {
    assert(remoteRepository != null);
    Completer _completer = Completer<void>();
    remoteRepository.fetch().then((List<Map> data) {

      SlotMachine parser(Map<dynamic,dynamic> map){
        return SlotMachine(
          standID: map['StandID'].toString(),
          machineTypeName: map['MachineTypeName'].toString(),
          machineStatusID: map['MachineStatusID'].toString(),
          machineStatusDescription: map['StatusDescription'].toString(),
          denom: double.parse(map['Denom'].toString()),
          updatedAt: DateTime.now().toUtc()
        );
      }

      List<SlotMachine> parsed = data.map<SlotMachine>((Map<dynamic,dynamic> map) => parser(map)).toList();
      _cache.data = parsed;
      _remoteSlotMachineController.add(_cache.data);
      _completer.complete();
    });
    return _completer.future;
  }

  void pushToController(SlotMachine received, String from) async {
    await _cache.updateEntry(received, from);
    _remoteSlotMachineController.add(_cache.data);
  }

  void listenAsync() {
    _slotMachineController = remoteRouting.Listen();
    _slotMachineController.stream.listen((SlotMachine sm) {
      pushToController(sm, 'EVENT');
    });
  }

  void cancelAsync() {
    if(_slotMachineController!=null && _slotMachineController.isClosed==false){
      _slotMachineController.close();
    }
  }

  List<SlotMachine> filter(String key) {
    if (key == null || key.isEmpty)
      return _cache.data;

    Iterable<SlotMachine> it = _cache.data.where((SlotMachine sm) => sm.standID.contains(key));
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
    });

    return _completer.future;

  }
}
