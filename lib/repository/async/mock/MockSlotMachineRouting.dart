import 'dart:async';
import 'dart:math';

import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/repository/async/IRouting.dart';

class MockSlotMachineRouting implements IRouting<SlotMachine> {

  @override
  StreamController<SlotMachine> Listen() {
    StreamController<SlotMachine> _controller = StreamController<SlotMachine>();

    final timer = Timer.periodic(Duration(milliseconds: 100), (Timer t){
      int min = 1;
      int max = 20;
      Random rnd = Random();
      num selection = min + rnd.nextInt(max - min);

      String standPartID = '${selection.toString().padLeft(2, '0')}';
      String _standID = '$standPartID-$standPartID-$standPartID';

      int minStatus = 0;
      int maxStatus = 3;
      Random rndStatus = Random();
      num selectionStatus = minStatus + rndStatus.nextInt(maxStatus - minStatus);

      _controller.add(SlotMachine(standID: _standID, machineStatusID: selectionStatus.toString()));
    });

    _controller.onCancel = (){
      timer.cancel();
    };

    return _controller;
  }

  @override
  Future PublishMessage(dynamic message) {
    throw UnimplementedError();
  }


}
