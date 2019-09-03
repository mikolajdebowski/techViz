import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techviz/service/client/MQTTClientService.dart';
import 'package:techviz/ui/networkIndicator.dart';

import '../_mocks/mqttInternalClientMock.dart';


void main(){

  Widget makeTestableWidget({Widget child}){
    return MaterialApp(
      home: child,
    );
  }

  MqttInternalClientMock _client;
  setUpAll(() async{
    _client = MqttInternalClientMock('tvdev.internal.bis2.net', '4D8E280D-B840-4773-898D-0F9F71B82ACA');
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

    // ignore: deprecated_member_use
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