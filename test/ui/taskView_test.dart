import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techviz/repository/taskRepository.dart';
import 'package:techviz/ui/taskView.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

void main() {
	setUp((){
		kiwi.Container container = kiwi.Container();
		container.registerInstance(TaskRepository(null,null));
	});

	testWidgets('Pumps TaskView', (WidgetTester tester) async {
		await tester.runAsync(() async {
			await tester.pumpWidget(MaterialApp(home: TaskView(GlobalKey())));
		});
	});
}
