import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:techviz/service/client/MQTTClientService.dart';
import '../../_mocks/mqttInternalClientMock.dart';
import '../../_mocks/rabbitmqConfigMock.dart';

void main() {
	RabbitMQConfigMock config = RabbitMQConfigMock();



	test('MQTTClientService should init', () async{
		MqttInternalClientMock _client = MqttInternalClientMock('irrelevantDeviceID');
		await MQTTClientService().init('irrelevantDeviceID', internalMqttClient: _client, config: config);
	});

	test('MQTTClientService should connect', () async{
		MqttInternalClientMock _client = MqttInternalClientMock( 'irrelevantDeviceID');
		await MQTTClientService().init('irrelevantDeviceID', internalMqttClient: _client, config: config);
		await MQTTClientService().connect();
	});

	test('MQTTClientService should throw an exception config is not given', () async{
		expect(MQTTClientService().init('irrelevantDeviceID'), throwsAssertionError);
	});

	setUp(() async{
		MqttInternalClientMock _client = MqttInternalClientMock('irrelevantDeviceID');
		await MQTTClientService().init('irrelevantDeviceID', internalMqttClient: _client, config: config);
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