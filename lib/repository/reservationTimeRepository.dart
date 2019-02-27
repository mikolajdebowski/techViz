import 'dart:async';
import 'package:techviz/model/reservationTime.dart';
import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/remoteRepository.dart';

class ReservationTimeRepository implements IRepository<SlotMachine>{

  IRemoteRepository remoteRepository;

  ReservationTimeRepository({this.remoteRepository}){
    assert(this.remoteRepository!=null);
  }

  @override
  Future fetch() {
    assert(this.remoteRepository!=null);
    return this.remoteRepository.fetch();
  }

  Future<List<ReservationTime>> getAll() {

    List<ReservationTime> list = [];
    list.add(ReservationTime(15, '15:00'));
    list.add(ReservationTime(30, '30:00'));
    list.add(ReservationTime(45, '45:00'));
    list.add(ReservationTime(60, '60:00'));

    return Future.value(list);
  }
}