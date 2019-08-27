import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:techviz/service/client/MQTTClientService.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:typed_data/typed_data.dart' as typed;

class MqttInternalClientMock extends mqtt.MqttClient{
	MqttInternalClientMock() : super('irrelevantURL', 'DEVICEID1');
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

void main() {

	test('MQTTClientService should init', () async{
		await MQTTClientService().init('irrelevantURL', 'irrelevantDeviceID', internalMqttClient: MqttInternalClientMock());
	});

	test('MQTTClientService should connect', () async{
		await MQTTClientService().init('irrelevantURL', 'irrelevantDeviceID', internalMqttClient: MqttInternalClientMock());
		await MQTTClientService().connect();
	});

	test('MQTTClientService should throw an exception if broker or deviceId is null', () async{
		expect(MQTTClientService().init(null, 'irrelevantDeviceID'), throwsAssertionError);
		expect(MQTTClientService().init('irrelevantURL', null), throwsAssertionError);
	});

	MqttInternalClientMock _client;
	setUp(() async{
		_client = MqttInternalClientMock();
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