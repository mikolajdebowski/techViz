
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:techviz/model/taskStatus.dart';
import 'package:techviz/presenter/managerViewPresenter.dart';
import 'package:techviz/repository/local/taskStatusTable.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/slotFloorRepository.dart';
import 'package:techviz/repository/taskRepository.dart';
import 'package:techviz/repository/taskStatusRepository.dart';
import 'package:techviz/repository/taskTypeRepository.dart';
import 'package:techviz/repository/userRepository.dart';
import 'package:techviz/ui/managerView.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

import '../presenter/managerViewPresenter_test.dart';
import '../repository/async/mock/taskRoutingMock.dart';
import '../repository/mock/localRepositoryMock.dart';
import '../repository/mock/slotFloorRemoteRepositoryMock.dart';
import '../repository/processor/mock/TaskRemoteRepositoryMock.dart';

class IManagerViewPresenterView extends Mock implements IManagerViewPresenter{}

class TaskStatusTableMock implements ITaskStatusTable{
  @override
  Future<List<TaskStatus>> getAll() {
    return Future<List<TaskStatus>>.value([]);
  }

  @override
  Future<int> insertAll(List<Map<String, dynamic>> list) {
    return Future<int>.value(1);
  }
}

class UserRemoteRepositoryMock implements IUserRemoteRepository{
  @override
  Future<Map> fetch() {
    throw UnimplementedError();
  }

  @override
  Future<List<Map>> teamAvailabilitySummary() {
    return Future<List<Map>>.value([]);
  }

  @override
  Future<List<Map>> usersBySectionsByTaskCount() {
    throw UnimplementedError();
  }
}

void main() {

  setUp((){
    kiwi.Container().registerInstance(TaskRepository(TaskRemoteRepositoryMock(), LocalRepositoryMock(), TaskRoutingMock()));
    Repository().taskTypeRepository = TaskTypeRepository(null, TaskTypeTableMock());
    Repository().taskStatusRepository = TaskStatusRepository(null, TaskStatusTableMock());
    Repository().slotFloorRepository = SlotFloorRepository(SlotFloorRemoteRepositoryMock(), null);
    Repository().userRepository = UserRepository(UserRemoteRepositoryMock(), null);
  });

  testWidgets('Pumps ManagerView', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(home: ManagerView(GlobalKey())));
    });

  });
}

