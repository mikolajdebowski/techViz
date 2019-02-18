import 'dart:async';

import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/repository/async/SlotMachineRouting.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/remoteRepository.dart';

class SlotMachineRepository implements IRepository<SlotMachine>{

  IRemoteRepository remoteRepository;
  StreamController<SlotMachine> _slotMachineController;
  StreamController<List<SlotMachine>> _remoteSlotMachineController;

  Stream<List<SlotMachine>> _stream;

  Stream<List<SlotMachine>> get stream{
    if(_stream==null){
      _stream = _remoteSlotMachineController.stream.asBroadcastStream();
    }
    return _stream;
  }

  List<SlotMachine> cache = [];


  SlotMachineRepository({this.remoteRepository}){
    _remoteSlotMachineController = StreamController<List<SlotMachine>>();
  }

  @override
  Future fetch() {
    assert(this.remoteRepository!=null);
    Completer _completer = Completer<void>();
    this.remoteRepository.fetch().then((dynamic data){
      //cache = (data as List<SlotMachine>).where((SlotMachine sm)=> sm.standID.contains('241')).toList();
      cache = (data as List<SlotMachine>).toList();
      _completer.complete();
    });
    return _completer.future;
  }

  void listenAsync() {
    _slotMachineController = SlotMachineRouting().Listen();
    _slotMachineController.stream.listen((SlotMachine sm){
      int idx = cache.indexWhere((SlotMachine _sm) => _sm.standID == sm.standID);
      if(idx>=0){
        cache[idx].machineStatusID = sm.machineStatusID;
      }
      _remoteSlotMachineController.add(cache);
    });
  }

  void cancelAsync(){
    _slotMachineController.close();
  }

  List<SlotMachine> filter(String key){
    if(key==null || key.length==0)
      return cache;

    Iterable<SlotMachine> it = cache.where((SlotMachine sm)=> sm.standID.contains(key));
    if(it!=null){
      return it.toList();
    }
    return [];
  }

  //TODO: IT WILL BE REMOVED
  @override
  Future listen(Function callback, Function callbackError) {
    throw UnimplementedError();
  }
}