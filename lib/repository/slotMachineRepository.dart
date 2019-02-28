import 'dart:async';

import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/repository/async/IRouting.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/remoteRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class SlotMachineRepository implements IRepository<SlotMachine> {
  IRemoteRepository remoteRepository;
  IRouting<SlotMachine> remoteRouting;

  StreamController<SlotMachine> _slotMachineController;
  StreamController<List<SlotMachine>> _remoteSlotMachineController;
  Stream<List<SlotMachine>> _stream;
  List<SlotMachine> cache = [];

  Stream<List<SlotMachine>> get stream {
    if (_stream == null) {
      _stream = _remoteSlotMachineController.stream.asBroadcastStream();
    }
    return _stream;
  }

  StreamController<List<SlotMachine>> get remoteSlotMachineController{
    return _remoteSlotMachineController;
  }

  void pushToController(SlotMachine slot){
    int idx = cache.indexWhere((SlotMachine _sm) => _sm.standID == slot.standID);
    if (idx >= 0) {
      cache[idx].machineStatusID = slot.machineStatusID;
    }
    _remoteSlotMachineController.add(cache);
  }

  SlotMachineRepository({this.remoteRepository, this.remoteRouting}) {
    assert(this.remoteRepository != null);
    assert(this.remoteRouting != null);

    _remoteSlotMachineController = StreamController<List<SlotMachine>>();
  }

  @override
  Future fetch() {
    print('fetch');
    assert(this.remoteRepository != null);
    Completer _completer = Completer<void>();
    this.remoteRepository.fetch().then((dynamic data) {
      print('remoteRepository fetched');
      cache = (data as List<SlotMachine>).toList();
      _remoteSlotMachineController.add(cache);
      _completer.complete();
    });
    return _completer.future;
  }

  void listenAsync() {
    _slotMachineController = remoteRouting.Listen();
    _slotMachineController.stream.listen((SlotMachine sm) {
      pushToController(sm);
    });
  }

  void cancelAsync() {
    _slotMachineController.close();
  }

  List<SlotMachine> filter(String key) {
    if (key == null || key.length == 0) return cache;

    Iterable<SlotMachine> it = cache.where((SlotMachine sm) => sm.standID.contains(key));
    if (it != null) {
      return it.toList();
    }
    return [];
  }

  Future setReservation(String userID, String standId, String playerID, String time) async {
    Completer _completer = Completer<void>();

    DeviceInfo info = await Utils.deviceInfo;

    var message = {'deviceId': '${info.DeviceID}', 'userId': '${userID}', 'standId': '${standId}', 'playerId': '${playerID}', 'reservationTimeId': int.parse(time), 'reservationStatusId': 0, 'siteId': 1};

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

    var message = {'deviceId': '${info.DeviceID}', 'standId': '${standId}', 'reservationStatusId': 1, 'siteId': 1};

    remoteRouting.PublishMessage(message).then((dynamic result) {
      _completer.complete(result);
    }).catchError((dynamic error){
      _completer.completeError(error);
    });

    return _completer.future;
  }
}
