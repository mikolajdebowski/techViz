import 'dart:async';
import 'package:techviz/model/reservationTime.dart';
import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/remoteRepository.dart';

class ReservationTimeRepository implements IRepository<SlotMachine>{

  IRemoteRepository remoteRepository;

  ReservationTimeRepository({this.remoteRepository}){
    assert( remoteRepository!=null);
  }

  @override
  Future fetch() {
    assert(remoteRepository!=null);
    return remoteRepository.fetch();
  }

  Future<List<ReservationTime>> getAll() {

    List<ReservationTime> list = [];
    list.add(ReservationTime(15, '15 minutes'));
    list.add(ReservationTime(30, '30 minutes'));
    list.add(ReservationTime(45, '45 minutes'));
    list.add(ReservationTime(60, '1 hour'));

    return Future.value(list);
  }
}