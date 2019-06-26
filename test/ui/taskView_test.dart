import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techviz/repository/taskRepository.dart';
import 'package:techviz/ui/taskView.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import '../repository/async/mock/taskRoutingMock.dart';
import '../repository/processor/mock/TaskRemoteRepositoryMock.dart';

void main() {
	final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
	const Size _kDefaultTestViewportSizeIphone5 = Size(1136,640);

	setUp((){
		kiwi.Container container = kiwi.Container();
		container.registerInstance(TaskRepository(TaskRemoteRepositoryMock(), null, TaskRoutingMock()));
	});

	testWidgets('Pumps TaskView', (WidgetTester tester) async {
		await binding.setSurfaceSize(_kDefaultTestViewportSizeIphone5);

		await tester.runAsync(() async {
			await tester.pumpWidget(MaterialApp(home: TaskView(GlobalKey())));
		});
	});
}
