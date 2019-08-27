import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/subjects.dart';
import 'package:techviz/common/deviceUtils.dart';
import 'package:techviz/common/model/deviceInfo.dart';
import 'package:techviz/service/client/MQTTClientService.dart';
import 'package:techviz/service/deviceService.dart';

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

class DeviceUtilsMock extends Mock implements IDeviceUtils{
	@override
	Future<DeviceInfo> get deviceInfo{
		DeviceInfo deviceInfo = DeviceInfo();
		deviceInfo.DeviceID = '123';
		deviceInfo.Model = 'test';
		deviceInfo.OSVersion = 'os1';
		deviceInfo.OSName = 'osTest';

		return Future<DeviceInfo>.value(deviceInfo);
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
		Future<void> updateFuture = _deviceService.update('irrelevantPayload');

		DeviceUtilsMock deviceUtilsMock = DeviceUtilsMock();
		DeviceInfo deviceInfo = await deviceUtilsMock.deviceInfo;
		String routingKeyForPublish = 'mobile.device.update.${deviceInfo.DeviceID}';
		_clientServiceMock.simulateStreamPayload(routingKeyForPublish, 'irrelevantPayload');

		expect(updateFuture, completion(any));
	});

}