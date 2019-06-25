import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techviz/repository/taskRepository.dart';
import 'package:techviz/ui/taskView.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import '../repository/async/mock/taskRoutingMock.dart';
import '../repository/processor/mock/TaskRemoteRepositoryMock.dart';

void main() {
	setUp((){
		kiwi.Container container = kiwi.Container();
		container.registerInstance(TaskRepository(TaskRemoteRepositoryMock(), null, TaskRoutingMock()));
	});

	testWidgets('Pumps TaskView', (WidgetTester tester) async {
		await tester.runAsync(() async {
			await tester.pumpWidget(MaterialApp(home: TaskView(GlobalKey())));
		});
	});
}
