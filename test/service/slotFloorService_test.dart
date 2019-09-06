import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/subjects.dart';
import 'package:techviz/service/client/MQTTClientService.dart';
import 'package:techviz/service/slotFloorService.dart';

import '../_mocks/deviceUtilsMock.dart';

class MQTTClientServiceMock extends Mock implements IMQTTClientService{
	Map<String,BehaviorSubject<dynamic>> subjects = <String,BehaviorSubject<dynamic>>{};

	@override
	Stream<dynamic> subscribe(String routingKey){
		subjects[routingKey] = BehaviorSubject<dynamic>();
		return subjects[routingKey].stream;
	}

	@override
  void unsubscribe(String routingKey);

	@override
	Stream<dynamic> streams(String routingKey){
		return subjects[routingKey].stream;
	}

	@override
  int publishMessage(String routingKey, dynamic message){
		return 1;
	}

	void simulateStreamPayload(String routingKey, dynamic message){
		subjects[routingKey] ??= BehaviorSubject<dynamic>();
		subjects[routingKey].add(message);
	}
}

void main() {
	ISlotFloorService _sectionService;
	MQTTClientServiceMock _clientServiceMock;
	DeviceUtilsMock _deviceUtilsMock = DeviceUtilsMock();

	setUp((){
		_clientServiceMock = MQTTClientServiceMock();
		_sectionService = SlotFloorService(mqttClientService: _clientServiceMock, deviceUtils: _deviceUtilsMock);
	});

	test('SlotFloorService - should reserve', () async {
		Future<void> updateFuture = _sectionService.setReservation('01-01-01', 'userID123', playerID: '123', time: 15);

		String routingKeyForCallback = 'mobile.reservation.update.${_deviceUtilsMock.deviceInfo.DeviceID}';
		_clientServiceMock.simulateStreamPayload(routingKeyForCallback, 'irrelevant');

		expect(updateFuture, completion(anything));
	});

	test('SlotFloorService - should cancel reservation', () async {
		Future<void> updateFuture = _sectionService.cancelReservation('01-01-01');

		String routingKeyForCallback = 'mobile.reservation.update.${_deviceUtilsMock.deviceInfo.DeviceID}';
		_clientServiceMock.simulateStreamPayload(routingKeyForCallback, 'irrelevant');

		expect(updateFuture, completion(anything));
	});

	test('SlotFloorService - listen async', () async {
		_sectionService.listenAsync();

		Map<String,dynamic> map = <String,dynamic>{};
		map['startedAt'] = DateTime.now().toIso8601String();
		map['data'] = <dynamic>[];

		Map<String,dynamic> entry = <String,dynamic>{};
		entry['standId'] = '01-01-01';
		entry['denom'] = 0.01;
		entry['machineTypeName'] = 'machinename';
		entry['statusId'] = '1';
		entry['statusDescription'] = 'Available';
		entry['startedAt'] = DateTime.now().toIso8601String();
		map['data'].add(entry);

		_clientServiceMock.simulateStreamPayload('mobile.machineStatus', json.encode(map));

	});
}
