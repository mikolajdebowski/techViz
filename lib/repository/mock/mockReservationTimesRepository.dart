import 'dart:async';
import 'package:techviz/repository/remoteRepository.dart';

class MockSlotMachineRepository implements IRemoteRepository<Map<int,String>> {

  @override
  Future<Map<int,String>> fetch() {
    throw UnimplementedError();
  }
}