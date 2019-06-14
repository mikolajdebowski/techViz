import 'dart:math';

import 'package:techviz/repository/slotFloorRepository.dart';

class SlotFloorRemoteRepositoryMock implements ISlotFloorRemoteRepository{
  @override
  Future<List<Map>> fetch() {
    throw UnimplementedError();
  }

  @override
  Future<List<Map>> slotFloorSummary() {
    //ENTRY EXAMPLE`
    //Denom,MachineTypeName,Mnum,PlayerID,ReservationTime,SiteID,StandID,StatusDescription,StatusID
    //"0.0100",
    //"1421 VOYAGES / ZHENG HE 88L/440C",
    //"17975",
    //"333",
    //"15",
    //"1",
    //"210305",
    //"Available",
    //"3"


    List<Map<String,dynamic>> listToReturn = <Map<String,dynamic>>[];

    //1000 with status != 0 (active games)
    for(int i =1; i< 1000; i++){
      Map<String,dynamic> mapEntry = <String,dynamic>{};
      mapEntry['Denom'] = '0.0100';
      mapEntry['MachineTypeName'] = '1421 VOYAGES / ZHENG HE 88L/440C';
      mapEntry['Mnum'] = '17975';
      mapEntry['PlayerID'] = '333';
      mapEntry['ReservationTime'] = '15';
      mapEntry['SiteID'] = '1';
      mapEntry['StandID'] = '$i.$i.$i';
      mapEntry['StatusDescription'] = 'random statuses';
      mapEntry['StatusID'] = 1 + (Random(1).nextInt(6-1));
      listToReturn.add(mapEntry);
    }

    //10 with status == 2 (in use)
    for(int i =10; i< 40; i++){
      Map<String,dynamic> mapEntry = <String,dynamic>{};
      mapEntry['Denom'] = '0.0100';
      mapEntry['MachineTypeName'] = '1421 VOYAGES / ZHENG HE 88L/440C';
      mapEntry['Mnum'] = '17975';
      mapEntry['PlayerID'] = '333';
      mapEntry['ReservationTime'] = '15';
      mapEntry['SiteID'] = '1';
      mapEntry['StandID'] = '$i.$i.$i';
      mapEntry['StatusDescription'] = 'random statuses';
      mapEntry['StatusID'] = 2;
      listToReturn.add(mapEntry);
    }

    //50 with status == 1 (reserved)
    for(int i =20; i< 50; i++){
      Map<String,dynamic> mapEntry = <String,dynamic>{};
      mapEntry['Denom'] = '0.0100';
      mapEntry['MachineTypeName'] = '1421 VOYAGES / ZHENG HE 88L/440C';
      mapEntry['Mnum'] = '17975';
      mapEntry['PlayerID'] = '333';
      mapEntry['ReservationTime'] = '15';
      mapEntry['SiteID'] = '1';
      mapEntry['StandID'] = '$i.$i.$i';
      mapEntry['StatusDescription'] = 'reserved';
      mapEntry['StatusID'] = 1;
      listToReturn.add(mapEntry);
    }

    //10 with status == 0 (OFFLINE)
    for(int i = 90; i< 99; i++){
      Map<String,dynamic> mapEntry = <String,dynamic>{};
      mapEntry['Denom'] = '0.0100';
      mapEntry['MachineTypeName'] = '1421 VOYAGES / ZHENG HE 88L/440C';
      mapEntry['Mnum'] = '17975';
      mapEntry['PlayerID'] = '333';
      mapEntry['ReservationTime'] = '15';
      mapEntry['SiteID'] = '1';
      mapEntry['StandID'] = '$i.$i.$i';
      mapEntry['StatusDescription'] = 'OFFLINE';
      mapEntry['StatusID'] = 0;
      listToReturn.add(mapEntry);
    }
    return Future<List<Map<String,dynamic>>>.value(listToReturn);
  }
}