import 'dart:async';
import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/repository/processor/processorLiveTable.dart';
import 'package:techviz/repository/processor/processorRepositoryFactory.dart';
import 'package:techviz/repository/remoteRepository.dart';

class ProcessorSlotMachineRepository extends ProcessorLiveTable<SlotMachine> implements IRemoteRepository<SlotMachine> {

  ProcessorSlotMachineRepository(){
    tableID = LiveTableType.TECHVIZ_MOBILE_SLOTS.toString();
  }

  @override
  Future<List<SlotMachine>> fetch() {
    var _completer = Completer<List<SlotMachine>>();

    super.fetch().then((dynamic livetableResult){
      var _columnNames = livetableResult[0] as List<String>;
      var _rows = livetableResult[1] as List<dynamic>;

      List<SlotMachine> listToReturn =  List<SlotMachine>();

      _rows.forEach((dynamic d) {
        dynamic values = d['Values'];

        var _standID = values[_columnNames.indexOf("StandID")] as String;
        var _machineTypeName = values[_columnNames.indexOf("MachineTypeName")] as String;
        var _machineStatusID = values[_columnNames.indexOf("StatusID")] as String;
        var _machineStatusDescription = values[_columnNames.indexOf("StatusDescription")] as String;
        var _denom = double.parse(values[_columnNames.indexOf("Denom")].toString());

        listToReturn.add(SlotMachine(
            _standID,
            _machineTypeName,
            machineStatusID:_machineStatusID,
            machineStatusDescription: _machineStatusDescription,
            denom: _denom));
      });

      _completer.complete(listToReturn);
    });

    return _completer.future;
  }

}