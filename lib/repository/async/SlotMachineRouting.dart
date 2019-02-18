import 'dart:async';
import 'dart:math';
import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/model/user.dart';
import 'package:techviz/repository/async/MessageClient.dart';

class SlotMachineRouting {
  String routingPattern = "mobile.slotmachine";

  StreamController<SlotMachine> Listen() {

    StreamController<SlotMachine> _controller = StreamController<SlotMachine>();
    final timer = Timer.periodic(Duration(milliseconds: 200), (Timer t){
      int min = 1;
      int max = 10;
      Random rnd = new Random();
      num selection = min + rnd.nextInt(max - min);

      String standID = '2412${selection.toString().padLeft(2, '0')}';

      int minStatus = 0;
      int maxStatus = 3;
      Random rndStatus = new Random();
      num selectionStatus = minStatus + rndStatus.nextInt(maxStatus - minStatus);

      _controller.add(SlotMachine(standID, 'GAME', machineStatusID: selectionStatus.toString()));
    });

    _controller.onCancel = (){
      timer.cancel();
    };

    return _controller;
  }

  Future PublishMessage(dynamic message) {
    return MessageClient().PublishMessage(message, routingPattern, parser: parser, wait: true);
  }

  User parser(dynamic json){
    return User(
        UserID: json["userID"] as String,
        UserStatusID: int.parse(json["userStatusID"].toString()));
  }


}