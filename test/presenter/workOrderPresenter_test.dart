
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/presenter/workOrderPresenter.dart';
import 'package:techviz/service/workOrderService.dart';

class WorkOrderViewMock extends Mock implements WorkOrderPresenterView{}

class WorkOrderServiceMock implements IWorkOrderService{
  @override
  Future create(String userID, int taskTypeID, {String location, String mNumber, String notes, DateTime dueDate}) {
    return Future<dynamic>.value();
  }
}

class WorkOrderServiceMockForTimeout implements IWorkOrderService{
	@override
	Future create(String userID, int taskTypeID, {String location, String mNumber, String notes, DateTime dueDate}) {
		Completer<dynamic> _completer = Completer<dynamic>();
		return _completer.future.timeout(Duration.zero);
	}
}

void main(){
	WorkOrderViewMock _view;
	WorkOrderPresenter _presenter;

	test('Create should complete', (){
		_presenter = WorkOrderPresenter(_view, workOrderService: WorkOrderServiceMock());
		expect(_presenter.create('tester', TaskType(1, 'type1', 'lookup')), completion(anything));
	});
}