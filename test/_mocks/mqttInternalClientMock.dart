
import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:typed_data/typed_data.dart' as typed;

class MqttInternalClientMock extends mqtt.MqttClient{
	MqttInternalClientMock(
			String deviceID
			) : super('irrelevant', deviceID);
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
