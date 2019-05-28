import 'dart:async';
import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/repository/processor/processorLiveTable.dart';
import 'package:techviz/repository/processor/processorRepositoryConfig.dart';
import 'package:techviz/repository/slotFloorRepository.dart';

class ProcessorSlotFloorRepository extends ProcessorLiveTable<SlotMachine> implements ISlotFloorRepository {

  final String TAG_SLOTFLOOR_SUMMARY = 'TECHVIZ_MOBILE_SLOTFLOOR_SUMMARY';

  ProcessorSlotFloorRepository(){
    tableID = LiveTableType.TECHVIZ_MOBILE_SLOTS.toString();
  }

  @override
  Future<List<SlotMachine>> fetch() {
    // TODO(rmathias): REFACTOR THIS METHOD TO RETURN A GENERIC FUTURE AND NOT A LIST OF THIS MODEL
    Completer<List<SlotMachine>> _completer = Completer<List<SlotMachine>>();

    super.fetch().then((dynamic livetableResult){
      var _columnNames = livetableResult[0] as List<String>;
      var _rows = livetableResult[1] as List<dynamic>;

      List<SlotMachine> listToReturn =  <SlotMachine>[];

      _rows.forEach((dynamic d) {
        dynamic values = d['Values'];

        var _standID = values[_columnNames.indexOf("StandID")] as String;
        var _machineTypeName = values[_columnNames.indexOf("MachineTypeName")] as String;
        var _machineStatusID = values[_columnNames.indexOf("StatusID")] as String;
        var _machineStatusDescription = values[_columnNames.indexOf("StatusDescription")] as String;
        var _denom = double.parse(values[_columnNames.indexOf("Denom")].toString());
        var _updatedAt = DateTime.now().toUtc();

        listToReturn.add(SlotMachine(
            standID: _standID,
            machineTypeName: _machineTypeName,
            machineStatusID:_machineStatusID,
            machineStatusDescription: _machineStatusDescription,
            denom: _denom,
            updatedAt: _updatedAt));
      });

      _completer.complete(listToReturn);
    });

    return _completer.future;
  }

  @override
  Future slotFloorSummary() {
    return fetchMapByTAG(TAG_SLOTFLOOR_SUMMARY);
  }
}