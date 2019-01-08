import 'dart:async';
import 'dart:convert';

import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/repository/processor/processorRepositoryFactory.dart';
import 'package:techviz/repository/remoteRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

class ProcessorSlotLookupRepository extends IRemoteRepository<SlotMachine> {

  List<SlotMachine> cache;

  @override
  Future fetch() {
    Completer _completer = Completer<void>();
    SessionClient client = SessionClient.getInstance();

    var config = ProcessorRepositoryConfig();
    String liveTableID = config.GetLiveTable(LiveTableType.TECHVIZ_MOBILE_SLOTS.toString()).ID;
    String url = 'live/${config.DocumentID}/${liveTableID}/select.json';

    client.get(url).catchError((Error onError){
      print(onError.toString());
      _completer.completeError(onError);
    }).then((String rawResult) async{
      dynamic decoded = json.decode(rawResult);
      List<dynamic> rows = decoded['Rows'] as List<dynamic>;

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

      cache = listToReturn;

      _completer.complete();

    }).catchError((Error onError){
      print(onError.toString());
      _completer.completeError(onError);
    });

    return _completer.future;
  }

  Future search(String query) async{
    if(cache==null || cache.length==0)
       await this.fetch();


    if(query==null || query.length==0)
      return cache;

    var filtered = cache.where((SlotMachine sm) => sm.standID.toLowerCase().contains(query.toLowerCase()) || sm.machineTypeName.toLowerCase().contains(query.toLowerCase()));
    return filtered!=null? filtered.toList() : List<SlotMachine>();
  }


}