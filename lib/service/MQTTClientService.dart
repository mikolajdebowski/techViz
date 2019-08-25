import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:rxdart/rxdart.dart';
abstract class IMQTTClientService{
	Future init(String broker, String deviceID, {bool secure = false, bool logging = false});
	void disconnect();
	Stream<dynamic> subscribe(String routingKey);
	void unsubscribe(String routingKey);
	int publishMessage(String routingKey, dynamic message);
	Stream<DateTime> get pong;
	Stream<dynamic> streams(String routingKey);
}

class MQTTClientService implements IMQTTClientService{
	static final MQTTClientService _instance = MQTTClientService._();
	factory MQTTClientService() => _instance;
	MQTTClientService._();

	mqtt.MqttClient _mqttClient;
	String _deviceID;
	String _broker;
	StreamSubscription _subscription;
	BehaviorSubject<DateTime> _pongSubject;
	Map<String,BehaviorSubject<dynamic>> _mapSubjects;

	@override
	Stream<DateTime> get pong => _pongSubject.stream;

	@override
	Stream<dynamic> streams(String routingKey){
		assert(_mapSubjects.containsKey(routingKey));
		return _mapSubjects[routingKey].stream;
	}

	@override
	Future init(String broker, String deviceID, {bool secure = false, bool logging = false}) async{
		assert(broker!=null);
		assert(deviceID!=null);

		_pongSubject = BehaviorSubject<DateTime>();
		_mapSubjects = {};

		broker = secure ? 'wss://$broker' : 'ws://$broker';
		broker = '$broker/mqtt';

		_deviceID = deviceID;
		_broker = broker;
		_mqttClient = mqtt.MqttClient(_broker, '');
		_mqttClient.useWebSocket = true;
		_mqttClient.port = secure ? 443 : 80;
		_mqttClient.logging(on: logging);
		_mqttClient.keepAlivePeriod = 10;
		_mqttClient.onConnected = _onConnected;
		_mqttClient.onDisconnected = _onDisconnected;
		_mqttClient.connectionMessage = mqtt.MqttConnectMessage()
				.withClientIdentifier(_deviceID)
				.withWillQos(mqtt.MqttQos.atLeastOnce)
				.keepAliveFor(10).startClean();

		_mqttClient.pongCallback = (){
			_pongSubject.add(DateTime.now());
		};
		_mqttClient.onSubscribed = (String topic){
			print('Subscribed to $topic');
		};
		_mqttClient.onUnsubscribed = (String topic){
			print('Unsubscribed of $topic');
		};
	}

	Future<void> connect() async{
		Completer _completer = Completer<void>();
		print('MQTT client connecting... $_broker at port ${_mqttClient.port}' );
		try {
			await _mqttClient.connect('mobile','mobile');
			_subscription = _mqttClient.updates.listen(_onMessage);

			_completer.complete();
		} catch (e) {
			print(e);
			disconnect();

			_completer.completeError(e);
		}
		return _completer.future;
	}

	@override
	void disconnect(){
		_mqttClient?.disconnect();
		_mqttClient = null;

		_subscription?.cancel();
		_mapSubjects.clear();
	}

	@override
	Stream<dynamic> subscribe(String routingKey){
		assert(_mapSubjects.containsKey(routingKey)==false);
		mqtt.Subscription subscription = _mqttClient.subscribe(routingKey, mqtt.MqttQos.atLeastOnce);
		if(subscription!=null){
			_mapSubjects[routingKey] = BehaviorSubject<dynamic>();
			return _mapSubjects[routingKey].stream;
		}
		return null;
	}

	@override
	void unsubscribe(String routingKey){
		_mqttClient.unsubscribe(routingKey);
		_mapSubjects[routingKey]?.close();
		_mapSubjects.remove(routingKey);
	}

	@override
	int publishMessage(String routingKey, dynamic message){
		final mqtt.MqttClientPayloadBuilder builder =
		mqtt.MqttClientPayloadBuilder();
		builder.addString(message);
		return _mqttClient.publishMessage(routingKey, mqtt.MqttQos.atLeastOnce, builder.payload);
	}

	void _onMessage(List<mqtt.MqttReceivedMessage> event) {
		print('Received ${event.length} events');
		event.forEach((mqtt.MqttReceivedMessage event){
			final mqtt.MqttPublishMessage recMess = event.payload as mqtt.MqttPublishMessage;
			final String messagePayload = mqtt.MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
			print('MQTT message: topic is <${event.topic}>, payload lenght is <-- ${messagePayload.length} -->');

			String routingKey = event.topic.replaceAll('/', '.');
			_mapSubjects[routingKey]?.add(messagePayload);
		});
	}

	void _onConnected() {
		print('MQTT client connected!');
	}

  void _onDisconnected() {
		print('MQTT client disconnected!');
  }
}