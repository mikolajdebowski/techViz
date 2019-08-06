import 'dart:async';
import 'package:techviz/model/slotMachine.dart';
import 'package:techviz/repository/async/MessageClient.dart';

abstract class ISlotMachineRouting{
  StreamController<List<SlotMachine>> Listen();
  Future PublishMessage(dynamic message);
  SlotMachine parser(dynamic json);
}

class SlotMachineRouting implements ISlotMachineRouting {
  String listeningRoutingKey = "mobile.machineStatus";
  String publishRoutingKey = "mobile.reservation";
  IMessageClient _messageClient;

  SlotMachineRouting(IMessageClient messageClient){
    _messageClient = messageClient;
    assert(messageClient!=null);
  }

  @override
  StreamController<List<SlotMachine>> Listen() {
    StreamController<List<SlotMachine>> _controller = StreamController<List<SlotMachine>>();
    final StreamController<dynamic> _queueController = _messageClient.ListenQueue(listeningRoutingKey, (dynamic sm){

      String startedAt = sm['startedAt'] as String;
      List<dynamic> data = sm['data'] as List<dynamic>;

      List<SlotMachine> outputList = [];

      data.forEach((dynamic entry){
        entry['startedAt'] = startedAt;
        outputList.add(parser(entry));
      });

      _controller.add(outputList);

    },  appendDeviceID: false );

    _controller.onCancel = (){
      _queueController.close();
    };

    return _controller;
  }

  @override
  Future PublishMessage(dynamic message) {
    return _messageClient.PublishMessage(message, publishRoutingKey, wait: true);
  }

  @override
  SlotMachine parser(dynamic json){
    return SlotMachine(
      dirty: false,
      standID: json['standId'].toString(),
      denom: double.parse(json['denom'].toString()),
      machineTypeName: json['machineTypeName'].toString(),
      machineStatusID:  json['statusId'].toString(),
      machineStatusDescription: json['statusDescription'].toString(),
      updatedAt: DateTime.parse(json['startedAt'].toString())
    );
  }
}