import 'dart:async';
import 'dart:convert';
import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/repository/async/IRouting.dart';
import 'package:techviz/repository/async/MessageClient.dart';

class SlotMachineRouting implements IRouting<SlotMachine> {

  StreamController<SlotMachine> Listen() {
    StreamController<SlotMachine> _controller = StreamController<SlotMachine>();
    final StreamController<dynamic> _queueController = MessageClient().ListenQueue("mobile.machineStatus", (dynamic sm){
      dynamic decoded = jsonDecode(sm.toString());
      dynamic startedAt = decoded['startedAt'];

      (decoded['data'] as List<dynamic>).forEach((dynamic entry){
        entry['startedAt'] = startedAt;
        _controller.add(parser(entry));
      });
    },  appendDeviceID: false );

    _controller.onCancel = (){
      _queueController.close();
    };

    return _controller;
  }

  Future PublishMessage(dynamic message) {
    return MessageClient().PublishMessage(message, "mobile.reservation", wait: true);
  }

  SlotMachine parser(dynamic json){
    return SlotMachine(
      json['standId'].toString(),
      machineStatusID:  json['statusId'].toString(),
      machineStatusDescription: json['statusDescription'].toString(),
      updatedAt: DateTime.parse(json['startedAt'].toString())
    );
  }
}