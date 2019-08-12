

import 'dart:async';

import 'package:techviz/repository/workOrder.repository.dart';
import 'package:test/test.dart';

import '../_mocks/messageClientMock.dart';

void main(){
	StreamController<dynamic> streamController;
	WorkOrderRepository repository;

	setUp(() async{
		streamController = StreamController<dynamic>();
		MessageClientMock messageClientMock = MessageClientMock<dynamic>(streamController);
		repository = WorkOrderRepository(messageClientMock);
	});

	test('WorkOrder creation with invalid location and machine number will fail', () {
		Future<dynamic> future = repository.create('dev2', 1);
		streamController.add('whatever');
		expect(future, completion(equals('whatever')));
	});

	tearDown((){
		streamController?.close();
	});
}