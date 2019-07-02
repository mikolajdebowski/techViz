import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techviz/bloc/taskViewBloc.dart';
import 'package:techviz/model/task.dart';
import 'package:techviz/model/taskStatus.dart';
import 'package:techviz/model/user.dart';
import 'package:techviz/session.dart';
import 'package:techviz/ui/taskView.dart';

void main() {
  final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
  const Size _kDefaultTestViewportSizeIphone5 = Size(1136, 640);

  setUpAll((){
    Session().user = User(userID: 'irina');
  });

  testWidgets('Pumps empty container when ', (WidgetTester tester) async {
    await binding.setSurfaceSize(_kDefaultTestViewportSizeIphone5);

    await tester.pumpWidget(MaterialApp(home: TaskView(GlobalKey())));

    expect(find.byKey(Key('taskViewEmptyContainer')), findsOneWidget);

    Task newTask = Task(dirty: 0, id: '123', location: '12-12-12', userID: 'irina', taskStatus: TaskStatus(id: 1));
    TaskViewBloc().update(newTask);
    await tester.pump(Duration.zero);

    expect(find.byType(ListView), findsOneWidget);
  });
}
