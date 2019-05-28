import 'dart:async';
import 'package:techviz/repository/remoteRepository.dart';

class MockOpenTasksRepository implements IRemoteRepository<dynamic> {

  @override
  Future fetch() {
    Completer<List<dynamic>> _completer = Completer<List<dynamic>>();
    Future.delayed(Duration(seconds: 1), (){

      List<dynamic> listToReturn =  <dynamic>[];
      for (int loop = 0; loop < 99; loop++) {
        listToReturn.add(loop);
      }

      dynamic d = Object();
      d.aa = '';

      _completer.complete(listToReturn);
    });
    return _completer.future;
  }
}