import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:rxdart/rxdart.dart';
import 'package:typed_data/typed_data.dart' as typed;

class MQTTClient{
	static final MQTTClient _instance = MQTTClient._();
	factory MQTTClient() => _instance;
	MQTTClient._();

	mqtt.MqttClient _mqttClient;
	String _deviceID;
	String _broker;
	StreamSubscription _subscription;
	final BehaviorSubject<DateTime> _pongSubject = BehaviorSubject<DateTime>();
	final Map<String,BehaviorSubject<dynamic>> _mapSubjects = {};


	//GETS
	Stream<DateTime> get pongStream => _pongSubject.stream;
	Stream<dynamic> streamFor(String routingKey){
		return _mapSubjects[routingKey].stream;
	}


	Future init(String broker, String deviceID) async{
		assert(broker!=null);
		assert(deviceID!=null);
		assert(_mqttClient==null); //TO AVOID BE CALLED TWICE

		_deviceID = deviceID;
		_broker = broker;
		_mqttClient = mqtt.MqttClient(_broker, '');
		//_mqttClient.useWebSocket = true;
		//_mqttClient.port = 80; // TODO(RMATHIAS): HOW TO DETECT THE PORT?
		_mqttClient.logging(on: true); //for now
		_mqttClient.keepAlivePeriod = 10;
		_mqttClient.onUnsubscribed = (String topic){
			print('onUnsubscribed $topic');
		};
		_mqttClient.onSubscribed = (String topic){
			print('onSubscribed $topic');
		};
		_mqttClient.onSubscribeFail = (String topic){
			print('onSubscribeFail $topic');
		};


		_mqttClient.onConnected = _onConnected;
		_mqttClient.onDisconnected = _onDisconnected;
		_mqttClient.connectionMessage = mqtt.MqttConnectMessage()
				.withClientIdentifier('mobile.SECOND')
				.withWillQos(mqtt.MqttQos.atLeastOnce)
				.keepAliveFor(10).startClean();

		_mqttClient.pongCallback = (){
			_pongSubject.add(DateTime.now());
		};

		print('MQTT client connecting... $_broker at port ${_mqttClient.port}' );

		try {
			await _mqttClient.connect('mobile','mobile');
		} catch (e) {
			print(e);
			print('ERROR: MQTT client connection failed - '
					'disconnecting, state is ${_mqttClient.connectionStatus.state}');
			return;
		}

		_subscription = _mqttClient.updates.listen(_onMessage);
	}

	void disconnect(){
		_subscription.cancel();
		_pongSubject.close();
		_mapSubjects.forEach((String key, BehaviorSubject subject){
			subject.close();
		});
		_mapSubjects.clear();
	}

	void subscribe(String routingKey){
		assert(_mapSubjects.containsKey(routingKey)==false);
		mqtt.Subscription subscription = _mqttClient.subscribe(routingKey, mqtt.MqttQos.atLeastOnce);
//		if(subscription!=null){
//			_mapSubjects[routingKey] = BehaviorSubject<dynamic>();
//		}
	}

	void unsubscribe(String routingKey){
			typed.Uint8Buffer buffer = MqttEncoding().getBytes(routingKey);
		print(buffer);
		_mqttClient.unsubscribe(routingKey);

//		_mapSubjects[routingKey]?.close();
//		_mapSubjects.remove(routingKey);
	}

	void _onMessage(List<mqtt.MqttReceivedMessage> event) {
		//print('Received ${event.length} events');
		//print('ConnState is ${_mqttClient.connectionStatus.state}');

		event.forEach((mqtt.MqttReceivedMessage event){
			final mqtt.MqttPublishMessage recMess = event.payload as mqtt.MqttPublishMessage;
			final String messagePayload = mqtt.MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
			//print('MQTT message: topic is <${event.topic}>, payload is <-- $messagePayload -->');

			String routingKey = event.topic.replaceAll('/', '.');
			_mapSubjects[routingKey]?.add(messagePayload);
		});
	}

	void _onConnected() {
		print('MQTT client connected');
	}

  void _onDisconnected() {
		print('MQTT client disconnected!');
  }

}

