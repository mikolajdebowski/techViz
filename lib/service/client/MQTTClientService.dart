import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:rxdart/rxdart.dart';

abstract class IMQTTClientService{
	Future init(String deviceID, {bool logging = false});
	void disconnect();
	Stream<dynamic> subscribe(String routingKey);
	void unsubscribe(String routingKey);
	int publishMessage(String routingKey, dynamic message);
	Stream<MQTTConnectionStatus> get status;
	Stream<dynamic> streams(String routingKey);
}

class MQTTClientService implements IMQTTClientService{
	static final MQTTClientService _instance = MQTTClientService._();
	factory MQTTClientService() => _instance;
	MQTTClientService._();

	//dynamic _mqttClient;
	mqtt.MqttClient _mqttClient;
	String _deviceID;
	String _broker;
	StreamSubscription _subscription;
	BehaviorSubject<MQTTConnectionStatus> _statusSubject;
	Map<String,BehaviorSubject<dynamic>> _mapSubjects;
	Timer _keepAliveTimer;
	bool _logging = false;

	@override
	Stream<MQTTConnectionStatus> get status => _statusSubject.stream;

	@override
	Stream<dynamic> streams(String routingKey){
		assert(_mapSubjects.containsKey(routingKey));
		return _mapSubjects[routingKey].stream;
	}

	@override
	Future init(String deviceID, { bool logging = false, dynamic internalMqttClient, RabbitmqConfig config}) async{

		assert(deviceID!=null);
		assert(config!=null);

		_logging = logging;
		_statusSubject = BehaviorSubject<MQTTConnectionStatus>();
		_mapSubjects = {};

		_deviceID = deviceID;
		_broker = config.broker;
		_mqttClient = internalMqttClient != null ? internalMqttClient : mqtt.MqttClient(_broker, '');
		_mqttClient.useWebSocket = true;
		_mqttClient.port = config.port;
//		_mqttClient.secure = config.secure;
		_mqttClient.secure = false;
		_mqttClient.logging(on: _logging);
		_mqttClient.keepAlivePeriod = 10;
		_mqttClient.onConnected = _onConnected;
		_mqttClient.onDisconnected = _onDisconnected;
		_mqttClient.connectionMessage = mqtt.MqttConnectMessage()
				.withClientIdentifier(_deviceID)
				.withWillQos(mqtt.MqttQos.atLeastOnce)
				.keepAliveFor(10).startClean();

		_mqttClient.pongCallback = (){
			if(_logging){
				print(_mqttClient.connectionStatus);
			}
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

		if(_statusSubject.isClosed)
			_statusSubject = BehaviorSubject<MQTTConnectionStatus>();

		_statusSubject.add(MQTTConnectionStatus.Connecting);
		try {
			await _mqttClient.connect('mobile','mobile');
			_subscription = _mqttClient.updates.listen(_onMessage);
			_statusSubject.add(MQTTConnectionStatus.Connected);
			_keepAliveChecker();
			_completer.complete();
		} catch (e) {
			_statusSubject.add(MQTTConnectionStatus.Error);
			print(e);
			_internalDisconnect();

			_completer.completeError(e);
		}
		return _completer.future;
	}

	@override
	void disconnect(){
		_keepAliveTimer?.cancel();
		_internalDisconnect();

		_statusSubject.add(MQTTConnectionStatus.Disconnected);
		_statusSubject?.close();
	}

	void _internalDisconnect(){
		_mqttClient?.disconnect();
		_subscription?.cancel();
	}

	@override
	Stream<dynamic> subscribe(String routingKey){
		mqtt.Subscription subscription = _mqttClient.subscribe(routingKey, mqtt.MqttQos.atLeastOnce);
		if(subscription!=null){
			if(_mapSubjects.containsKey(routingKey)==false){
				_mapSubjects[routingKey] = BehaviorSubject<dynamic>();
			}
			return _mapSubjects[routingKey].stream;
		}
		throw Exception('Can\'t subscribe to the topic/routing key $routingKey');
	}

	void _resubscribeTopics(){
		_mapSubjects.keys.forEach((String topic){
			subscribe(topic);
		});
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

		if(message is Map){
			message = json.encode(message);
		}

		builder.addString(message);

		int messageId = _mqttClient.publishMessage(routingKey, mqtt.MqttQos.atLeastOnce, builder.payload);
		return messageId;
	}

	void _keepAliveChecker(){
		if(_keepAliveTimer!=null && _keepAliveTimer.isActive)
			return;

		_keepAliveTimer = Timer.periodic(Duration(seconds: 5), (Timer timer){
			if(timer.isActive==false)
				return;

			if(_mqttClient.connectionStatus==null){
				if(_logging)
					print('_keepAlive connectionStatus is null, reconnecting ${timer.tick}');

				_reconnect();
				return;
			}

			if(_mqttClient.connectionStatus.state == mqtt.MqttConnectionState.connected ||
					_mqttClient.connectionStatus.state == mqtt.MqttConnectionState.connecting ||
					_mqttClient.connectionStatus.state == mqtt.MqttConnectionState.disconnecting){

				if(_logging)
					print('_keepAlive ${_mqttClient.connectionStatus.state} ${timer.tick}');

				_statusSubject.add(_getState(_mqttClient.connectionStatus.state));
				return;
			}

			if(_logging)
				print('_keepAlive calling _reconnect ${timer.tick}');

			_reconnect();

		});
	}

	void _reconnect() async{
		try{
			await MQTTClientService().connect();
			_resubscribeTopics();
		}
		catch(error){
			print(error);
		}
	}

	MQTTConnectionStatus _getState(mqtt.MqttConnectionState state){
		switch(state){
			case mqtt.MqttConnectionState.connected:
				return MQTTConnectionStatus.Connected;
			case mqtt.MqttConnectionState.connecting:
				return MQTTConnectionStatus.Connecting;
			case mqtt.MqttConnectionState.disconnected:
				return MQTTConnectionStatus.Disconnected;
			default:
				return MQTTConnectionStatus.Unknown;
		}
	}

	void _onMessage(List<mqtt.MqttReceivedMessage> events) {

		events.forEach((mqtt.MqttReceivedMessage event){
			final mqtt.MqttPublishMessage recMess = event.payload as mqtt.MqttPublishMessage;

			final String messagePayload = mqtt.MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

			if(_logging)
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

enum MQTTConnectionStatus{
	Disconnected,
	Connected,
	Connecting,
	Error,
	Unknown
}

class RabbitmqConfig{
	String broker;
	int port;
	bool secure;
	String exchangeName;
}