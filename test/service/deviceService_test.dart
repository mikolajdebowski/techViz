import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/subjects.dart';
import 'package:techviz/common/model/deviceInfo.dart';
import 'package:techviz/service/client/MQTTClientService.dart';
import 'package:techviz/service/deviceService.dart';

import '../_mocks/deviceUtilsMock.dart';

class MQTTClientServiceMock extends Mock implements IMQTTClientService{
	Map<String,BehaviorSubject<dynamic>> subjects = <String,BehaviorSubject<dynamic>>{};

	@override
	Stream<dynamic> subscribe(String routingKey){
		subjects[routingKey] = BehaviorSubject<dynamic>();
		return subjects[routingKey].stream;
	}

	@override
	Stream<dynamic> streams(String routingKey){
		return subjects[routingKey].stream;
	}

	void simulateStreamPayload(String routingKeyCallback, dynamic message){
		subjects[routingKeyCallback].add(message);
	}
}

void main() {
	DeviceService _deviceService;
	MQTTClientServiceMock _clientServiceMock;
	setUp(() async{
		_clientServiceMock = MQTTClientServiceMock();
		_deviceService = DeviceService(mqttClientService: _clientServiceMock, deviceUtils: DeviceUtilsMock());
	});

	test('update Future should complete', () async {
		Future<void> updateFuture = _deviceService.update('irrelevantUserId');

		DeviceUtilsMock deviceUtilsMock = DeviceUtilsMock();
		DeviceInfo deviceInfo = deviceUtilsMock.deviceInfo;
		String routingKeyForPublish = 'mobile.device.update.${deviceInfo.DeviceID}';
		_clientServiceMock.simulateStreamPayload(routingKeyForPublish, 'irrelevantPayload');

		expect(updateFuture, completion(anything));
	});
}
