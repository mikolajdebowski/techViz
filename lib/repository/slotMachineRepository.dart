import 'dart:async';

import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/repository/async/IRouting.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/remoteRepository.dart';

class SlotMachineRepository implements IRepository<SlotMachine>{

  IRemoteRepository remoteRepository;
  IRouting<SlotMachine> remoteRouting;

  StreamController<SlotMachine> _slotMachineController;
  StreamController<List<SlotMachine>> _remoteSlotMachineController;
  Stream<List<SlotMachine>> _stream;
  List<SlotMachine> cache = [];


  Stream<List<SlotMachine>> get stream{
    if(_stream==null){
      _stream = _remoteSlotMachineController.stream.asBroadcastStream();
    }
    return _stream;
  }

  SlotMachineRepository({this.remoteRepository, this.remoteRouting}){
    assert(this.remoteRepository!=null);
    assert(this.remoteRouting!=null);

    _remoteSlotMachineController = StreamController<List<SlotMachine>>();
  }

  @override
  Future fetch() {
    print('fetch');
    assert(this.remoteRepository!=null);
    Completer _completer = Completer<void>();
    this.remoteRepository.fetch().then((dynamic data){
      print('remoteRepository fetched');
      cache = (data as List<SlotMachine>).toList();
      _remoteSlotMachineController.add(cache);
      _completer.complete();
    });
    return _completer.future;
  }

  void listenAsync() {
    _slotMachineController = remoteRouting.Listen();
    _slotMachineController.stream.listen((SlotMachine sm){
      print('listenAsync received ${sm.standID}');
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
}