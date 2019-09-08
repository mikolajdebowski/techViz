import 'dart:async';
import 'package:techviz/model/slotMachine.dart';

abstract class ISlotFloorRemoteRepository {
  Future<List<Map>> slotFloorSummary();
}

class SlotFloorRepository {
  ISlotFloorRemoteRepository remoteRepository;

  SlotFloorRepository(this.remoteRepository);

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
    }).catchError((dynamic error){
      _completer.completeError(error);
    });

    return _completer.future;
  }
}
