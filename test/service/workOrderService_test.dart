
import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/subjects.dart';
import 'package:techviz/common/model/deviceInfo.dart';
import 'package:techviz/service/client/MQTTClientService.dart';
import 'package:techviz/service/workOrderService.dart';

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
	DeviceUtilsMock _deviceUtilsMock;
	WorkOrderService _workOrderService;
	MQTTClientServiceMock _clientServiceMock;
	setUp(() {
		_deviceUtilsMock = DeviceUtilsMock();
		_clientServiceMock = MQTTClientServiceMock();
		_workOrderService = WorkOrderService(mqttClientService: _clientServiceMock, deviceUtils: _deviceUtilsMock);
	});

	test('should throw assertion error if either location and machine number is not given', () async {
		expect(_workOrderService.create('tester', 1), throwsAssertionError);
	});

	test('should throw Invalid Location/Asset Number', () async {
		Future future = _workOrderService.create('tester', 1, location: 'location_x', mNumber: 'machinenumber_y');
		DeviceInfo deviceInfo = _deviceUtilsMock.deviceInfo;
		String routingKeyForPublish = 'mobile.workorder.update.${deviceInfo.DeviceID}';
		_clientServiceMock.simulateStreamPayload(routingKeyForPublish, '{"validmachine": 0}');

		expect(future, throwsA(equals('Invalid Location/Asset Number')));
	});

	test('should complete Future without errors', () async {
		Future future = _workOrderService.create('tester', 1, location: 'location_x', mNumber: 'machinenumber_y');
		DeviceInfo deviceInfo = _deviceUtilsMock.deviceInfo;
		String routingKeyForPublish = 'mobile.workorder.update.${deviceInfo.DeviceID}';
		_clientServiceMock.simulateStreamPayload(routingKeyForPublish, '{"validmachine": 1}');

		expect(future, completion(anything));
	});
}
