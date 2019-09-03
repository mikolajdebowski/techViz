import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/subjects.dart';
import 'package:techviz/common/model/deviceInfo.dart';
import 'package:techviz/service/client/MQTTClientService.dart';
import 'package:techviz/service/userService.dart';

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
	IUserService _userService;
	MQTTClientServiceMock _clientServiceMock;
	setUp(() async{
		_clientServiceMock = MQTTClientServiceMock();
		_userService = UserService(mqttClientService: _clientServiceMock, deviceUtils: DeviceUtilsMock());
	});

	test('update should throw assertion error if neither roleId and statusId are not given', () async {
		expect(_userService.update('irrelevantPayload'), throwsAssertionError);
	});

	test('update should throw assertion error if userId is null', () async {
		expect(_userService.update(null), throwsAssertionError);
	});

	test('update Future should complete if statusId is given', () async {
		Future<void> updateFuture = _userService.update('irrelevantUserId', statusID: 1);
		DeviceInfo _deviceInfo = DeviceUtilsMock().deviceInfo;
		String routingKeyForPublish = 'mobile.user.update.${_deviceInfo.DeviceID}';
		_clientServiceMock.simulateStreamPayload(routingKeyForPublish, 'irrelevantPayload');

		expect(updateFuture, completion(anything));
	});

	test('update Future should complete if roleId is given', () async {
		Future<void> updateFuture = _userService.update('irrelevantUserId', roleID: "1");
		DeviceInfo _deviceInfo = DeviceUtilsMock().deviceInfo;
		String routingKeyForPublish = 'mobile.user.update.${_deviceInfo.DeviceID}';
		_clientServiceMock.simulateStreamPayload(routingKeyForPublish, 'irrelevantPayload');

		expect(updateFuture, completion(anything));
	});

}