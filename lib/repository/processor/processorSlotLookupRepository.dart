import 'dart:async';
import 'dart:convert';

import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/processor/processorRepositoryFactory.dart';
import 'package:techviz/repository/remoteRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class ProcessorSlotLookupRepository extends IRemoteRepository<SlotMachine> {


  @override
  Future fetch() {
    throw UnimplementedError();
  }

  Future<List<SlotMachine>> search(String query) {

    Completer<List<SlotMachine>> _completer = Completer<List<SlotMachine>>();
    SessionClient client = SessionClient.getInstance();

    var config = ProcessorRepositoryConfig();
    String liveTableID = config.GetLiveTable(LiveTableType.TECHVIZ_MOBILE_SLOTS.toString()).ID;
    String url = 'live/${config.DocumentID}/${liveTableID}/select.json';

    client.get(url).catchError((Error onError){
      print(onError.toString());
      _completer.completeError(onError);
    }).then((String rawResult) async{
      Map<String,dynamic> decoded = json.decode(rawResult);
      List<dynamic> rows = decoded['Rows'];

      var _columnNames = (decoded['ColumnNames'] as String).split(',');

      List<SlotMachine> listToReturn =  List<SlotMachine>();

      rows.forEach((dynamic d) {
        dynamic values = d['Values'];

        var _standID = values[_columnNames.indexOf("StandID")] as String;
        var _machineTypeName = values[_columnNames.indexOf("MachineTypeName")] as String;
        var _machineStatusID = values[_columnNames.indexOf("MachineStatusID")] as String;
        var _reservationStatusID = values[_columnNames.indexOf("ReservationStatusID")] as String;
        var _reservationTime = values[_columnNames.indexOf("ReservationTime")] as String;
        var _denom = double.parse(values[_columnNames.indexOf("Denom")].toString());

        listToReturn.add(SlotMachine(
            _standID,
            _machineTypeName,
            machineStatusID:_machineStatusID,
              reservationStatusID: _reservationStatusID,
              reservationTime: _reservationTime,
              denom: _denom));
      });
      _completer.complete(listToReturn);

    }).catchError((Error onError){
      print(onError.toString());
      _completer.completeError(onError);
    });

    return _completer.future;

  }

}