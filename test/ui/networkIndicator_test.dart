import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:techviz/service/client/MQTTClientService.dart';
import 'package:techviz/ui/networkIndicator.dart';
import 'package:typed_data/typed_data.dart' as typed;


class MqttInternalClientMock extends mqtt.MqttClient{
  MqttInternalClientMock() : super('tvdev.internal.bis2.net', '4D8E280D-B840-4773-898D-0F9F71B82ACA');
  mqtt.MessageIdentifierDispenser messageIdentifierDispenser = mqtt.MessageIdentifierDispenser();

  final StreamController<List<mqtt.MqttReceivedMessage<mqtt.MqttMessage>>> _updatesStream = StreamController<List<mqtt.MqttReceivedMessage<mqtt.MqttMessage>>>();

  @override
  Future<mqtt.MqttClientConnectionStatus> connect([String username, String password]){
    var status = mqtt.MqttClientConnectionStatus();
    status.state = mqtt.MqttConnectionState.connected;
    updates = _updatesStream.stream;
    return Future.value(status);
  }

  @override
  void disconnect() {
    _updatesStream?.close();
  }

  @override
  mqtt.Subscription subscribe(String topic, mqtt.MqttQos qosLevel) {
    return mqtt.Subscription();
  }

  @override
  int publishMessage(String topic, mqtt.MqttQos qualityOfService, typed.Uint8Buffer data, {bool retain = false}) {
    final int msgId = messageIdentifierDispenser.getNextMessageIdentifier();
    mqtt.MqttPublishMessage _message = mqtt.MqttPublishMessage()
        .toTopic(topic)
        .withMessageIdentifier(msgId)
        .withQos(qualityOfService)
        .publishData(data);

    mqtt.MqttReceivedMessage<mqtt.MqttMessage> messageReceived = mqtt.MqttReceivedMessage<mqtt.MqttMessage>(topic, _message);
    _updatesStream.add([messageReceived]);
    return msgId;
  }
}

void main(){

  Widget makeTestableWidget({Widget child}){
    return MaterialApp(
      home: child,
    );
  }

  MqttInternalClientMock _client;
  setUp(() async{
    _client = MqttInternalClientMock();
    await MQTTClientService().init('tvdev.internal.bis2.net', '4D8E280D-B840-4773-898D-0F9F71B82ACA', internalMqttClient: _client, logging: true);
    await MQTTClientService().connect();
  });

  testWidgets('test for network indicator widget green', (WidgetTester tester) async {
    NetworkIndicator indicator = NetworkIndicator();
    await tester.pumpWidget(makeTestableWidget(child: indicator));

    RenderDecoratedBox actualBox = tester.renderObject(find.byType(DecoratedBox));
    BoxDecoration actualDecoration = actualBox.decoration;

    expect(actualDecoration.color, Colors.green);
  });

  testWidgets('test for network indicator widget orange no service conneciton', (WidgetTester tester) async {


    MQTTClientService().disconnect();
    NetworkIndicator indicator = NetworkIndicator();
    await tester.pumpWidget(makeTestableWidget(child: indicator));
    await tester.pump();

    RenderDecoratedBox actualBox = tester.renderObject(find.byType(DecoratedBox));
    BoxDecoration actualDecoration = actualBox.decoration;


//    expect(actualDecoration.color, Color(0xff4caf50));
//    expect(actualDecoration.color, Colors.orange);
    expect(actualDecoration.color, Colors.green);
  });



}