import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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
  setUpAll(() async{
    _client = MqttInternalClientMock();
    await MQTTClientService().init('tvdev.internal.bis2.net', '4D8E280D-B840-4773-898D-0F9F71B82ACA', internalMqttClient: _client, logging: false);
    await MQTTClientService().connect();

    Connectivity.methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'check':
          return 'wifi';
        default:
          return null;
      }
    });
  });


  testWidgets('test for network indicator widget GREEN', (WidgetTester tester) async {
    NetworkIndicator indicator = NetworkIndicator();
    await tester.pumpWidget(makeTestableWidget(child: indicator));

    RenderDecoratedBox actualBox = tester.renderObject(find.byType(DecoratedBox));
    BoxDecoration actualDecoration = actualBox.decoration;

    expect(actualDecoration.color, Colors.green);
  });


  testWidgets('test for network indicator widget ORANGE no viz service conneciton', (WidgetTester tester) async {

    NetworkIndicator indicator = NetworkIndicator();
    await tester.pumpWidget(makeTestableWidget(child: indicator));

    MQTTClientService().disconnect();
    await tester.pump();

    RenderDecoratedBox actualBox = tester.renderObject(find.byType(DecoratedBox));
    BoxDecoration actualDecoration = actualBox.decoration;
    expect(actualDecoration.color, Colors.orange);
  });



  testWidgets('test for network indicator widget RED no internet conneciton', (WidgetTester tester) async {
    NetworkIndicator indicator = NetworkIndicator();
    await tester.pumpWidget(makeTestableWidget(child: indicator));

    await BinaryMessages.handlePlatformMessage(
      Connectivity.eventChannel.name,
      Connectivity.eventChannel.codec.encodeSuccessEnvelope('none'),
          (_) {},
    );
    await tester.pump();

    RenderDecoratedBox actualBox = tester.renderObject(find.byType(DecoratedBox));
    BoxDecoration actualDecoration = actualBox.decoration;
    expect(actualDecoration.color, Colors.red);
  });


}