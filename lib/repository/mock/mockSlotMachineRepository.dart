import 'dart:async';
import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/repository/remoteRepository.dart';

class MockSlotMachineRepository implements IRemoteRepository<SlotMachine> {

  @override
  Future<List<SlotMachine>> fetch() {
    var _completer = Completer<List<SlotMachine>>();
    Future.delayed(Duration(seconds: 1), (){

      List<SlotMachine> listToReturn =  <SlotMachine>[];
      for (int loop = 0; loop < 99; loop++) {

        String standPartID = '${loop.toString().padLeft(2, '0')}';

        String _standID = '$standPartID-$standPartID-$standPartID';
        String _machineTypeName = 'GAME $standPartID';
        String _machineStatusID = '1';
        String _machineStatusDescription = 'ETC';
        double _denom = 0.01;

        SlotMachine inst = SlotMachine(
            standID: _standID,
            machineTypeName: _machineTypeName,
            machineStatusID:_machineStatusID,
            machineStatusDescription: _machineStatusDescription,
            denom: _denom);

        listToReturn.add(inst);
      }
      _completer.complete(listToReturn);
    });
    return _completer.future;
  }


}