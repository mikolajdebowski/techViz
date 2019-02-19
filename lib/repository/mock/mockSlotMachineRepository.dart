import 'dart:async';
import 'dart:math';
import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/repository/remoteRepository.dart';

class MockSlotMachineRepository implements IRemoteRepository<SlotMachine> {

  @override
  Future<List<SlotMachine>> fetch() {
    var _completer = Completer<List<SlotMachine>>();
    Future.delayed(Duration(seconds: 1), (){

      List<SlotMachine> listToReturn =  List<SlotMachine>();
      for (int loop = 0; loop < 1000; loop++) {
        listToReturn.add(random());
      }
      _completer.complete(listToReturn);
    });
    return _completer.future;
  }

  String randomID(){
    int min = 1;
    int max = 99;
    num selection = min + Random().nextInt(max - min);
    return '${selection.toString().padLeft(2, '0')}';
  }

  SlotMachine random(){

    var _standID = '${randomID()}-${randomID()}-${randomID()}';
    var _machineTypeName = 'GAME ${randomID()}';
    var _machineStatusID = '1';
    var _machineStatusDescription = 'ETC';
    var _denom = 0.01;

    return SlotMachine(
        _standID,
        machineTypeName: _machineTypeName,
        machineStatusID:_machineStatusID,
        machineStatusDescription: _machineStatusDescription,
        denom: _denom);

  }
}