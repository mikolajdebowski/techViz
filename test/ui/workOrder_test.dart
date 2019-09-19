import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/model/user.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/taskTypeRepository.dart';
import 'package:techviz/session.dart';
import 'package:techviz/ui/workOrder.dart';

class TaskTypeRepositoryMock implements ITaskTypeRepository{
	@override
  Future fetch() {
		throw UnimplementedError();
  }

  @override
  Future<List<TaskType>> getAll({TaskTypeLookup lookup}) {
    List<TaskType> taskTypes = [];
    taskTypes.add(TaskType(1, 'Type 1', 'workType'));
		taskTypes.add(TaskType(2, 'Type 2', 'workType'));
		taskTypes.add(TaskType(3, 'Type 3', 'workType'));

		return Future<List<TaskType>>.value(taskTypes);
  }
}

void main() {
	setUp((){
		Session().user = User(userID: 'dev2');
		Repository().taskTypeRepository = TaskTypeRepositoryMock();
	});

	testWidgets('WorkOrder form validation', (WidgetTester tester) async {
		await tester.pumpWidget(MaterialApp(home: WorkOrder()));

		Finder okBtnFinder = find.byKey(Key('okBtn'));

		await tester.tap(okBtnFinder);
		await tester.pumpAndSettle(Duration(milliseconds: 500));

		expect(find.text('Location or Asset Number is required'), findsOneWidget);
		expect(find.text('Asset Number or Location is required'), findsOneWidget);
		expect(find.text('Type is required'), findsOneWidget);

		await tester.enterText(find.byKey(Key('locationFormField')), '01-01-01');
		await tester.tap(okBtnFinder);
		await tester.pumpAndSettle(Duration(milliseconds: 500));

		expect(find.text('Location or Asset Number is required'), findsNothing);
		expect(find.text('Asset Number or Location is required'), findsNothing);
		expect(find.text('Type is required'), findsOneWidget);

		//TAPS ON THE DROPDOWNFORMFIELD
		Finder vizDropdownFormFieldFinder = find.byKey(Key('typeFormField'));
		await tester.tap(vizDropdownFormFieldFinder);
		await tester.pumpAndSettle(Duration(milliseconds: 500));

		//SELECTS FIRST TASK TYPE
		Finder dropdownFormFieldTaskType1Finder = find.byKey(Key('taskType_1'));
		await tester.tap(dropdownFormFieldTaskType1Finder.first);
		await tester.pumpAndSettle(Duration(milliseconds: 500));

		await tester.tap(okBtnFinder);
		await tester.pumpAndSettle(Duration(milliseconds: 500));
		expect(find.text('Type is required'), findsNothing);
	});
}
