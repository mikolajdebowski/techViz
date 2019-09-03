import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:techviz/service/client/MQTTClientService.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:typed_data/typed_data.dart' as typed;

import '../../_mocks/mqttInternalClientMock.dart';

void main() {
	test('MQTTClientService should init', () async{
		MqttInternalClientMock _client = MqttInternalClientMock('irrelevantURL', 'irrelevantDeviceID');
		await MQTTClientService().init('irrelevantURL', 'irrelevantDeviceID', internalMqttClient: _client);
	});

	test('MQTTClientService should connect', () async{
		MqttInternalClientMock _client = MqttInternalClientMock('irrelevantURL', 'irrelevantDeviceID');
		await MQTTClientService().init('irrelevantURL', 'irrelevantDeviceID', internalMqttClient: _client);
		await MQTTClientService().connect();
	});

	test('MQTTClientService should throw an exception if broker or deviceId is null', () async{
		expect(MQTTClientService().init(null, 'irrelevantDeviceID'), throwsAssertionError);
		expect(MQTTClientService().init('irrelevantURL', null), throwsAssertionError);
	});

	setUp(() async{
		MqttInternalClientMock _client = MqttInternalClientMock('irrelevantURL', 'irrelevantDeviceID');
		await MQTTClientService().init('irrelevantURL', 'irrelevantDeviceID', internalMqttClient: _client);
		await MQTTClientService().connect();
	});

	test('MQTTClientService should subscribe', () async{
		String routingKey = 'ROUTING_KEY';

		Stream<dynamic> subscription = MQTTClientService().subscribe(routingKey);
		expect(subscription!=null, true);
	});

	test('MQTTClientService should publish a message and return a message ID', () async{
		String routingKey = 'ROUTING_KEY';

		int msgID = MQTTClientService().publishMessage(routingKey, 'TEST');

		expect(msgID, 1);
	});

	test('MQTTClientService should receive a message from the stream', () async{
		String routingKey = 'ROUTING_KEY';

		MQTTClientService().subscribe(routingKey);
		MQTTClientService().streams(routingKey).listen((dynamic result){
			expect(result.toString(), 'TEST');
		});

		MQTTClientService().publishMessage(routingKey, 'TEST');
	});

}