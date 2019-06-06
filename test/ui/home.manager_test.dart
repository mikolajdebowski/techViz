
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:techviz/model/taskStatus.dart';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/presenter/managerViewPresenter.dart';
import 'package:techviz/repository/local/taskStatusTable.dart';
import 'package:techviz/repository/local/taskTypeTable.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/slotFloorRepository.dart';
import 'package:techviz/repository/taskRepository.dart';
import 'package:techviz/repository/taskStatusRepository.dart';
import 'package:techviz/repository/taskTypeRepository.dart';
import 'package:techviz/repository/userRepository.dart';
import 'package:techviz/ui/home.manager.dart';

import '../repository/mock/localRepositoryMock.dart';
import '../repository/mock/slotFloorRemoteRepositoryMock.dart';

class IManagerViewPresenterView extends Mock implements IManagerViewPresenter{

}

class TaskRemoteRepositoryMock implements ITaskRemoteRepository{
  @override
  Future fetch() {
    throw UnimplementedError();
  }

  @override
  Future openTasksSummary() {

    List<Map<String,dynamic>> listToReturn = <Map<String,dynamic>>[];

    for(int i =0; i< 100; i++){
      Map<String,dynamic> mapEntry = <String,dynamic>{};
      mapEntry['_ID'] = i.toString();
      mapEntry['Location'] = i.toString();
      mapEntry['TaskTypeID'] = i.toString();
      mapEntry['TaskStatusID'] = i.toString();
      mapEntry['UserID'] = i.toString();
      mapEntry['ElapsedTime'] = i.toString();
      mapEntry['TaskUrgencyID'] = i.toString();
      mapEntry['ParentID'] = i.toString();
      mapEntry['IsTechTask'] = false;
    }
    return Future<List<Map<String,dynamic>>>.value(listToReturn);
  }
}

class TaskTypeTableMock implements ITaskTypeTable{
  @override
  Future<List<TaskType>> getAll({TaskTypeLookup lookup}) {
    return Future<List<TaskType>>.value([]);
  }

  @override
  Future<int> insertAll(List<Map<String, dynamic>> list) {
    return Future<int>.value(1);
  }
}

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
    Repository().taskRepository = TaskRepository(TaskRemoteRepositoryMock(), LocalRepositoryMock());
    Repository().taskTypeRepository = TaskTypeRepository(null, TaskTypeTableMock());
    Repository().taskStatusRepository = TaskStatusRepository(null, TaskStatusTableMock());
    Repository().slotFloorRepository = SlotFloorRepository(SlotFloorRemoteRepositoryMock(), null);
    Repository().userRepository = UserRepository(UserRemoteRepositoryMock(), null, null);
  });

  testWidgets('Manager view pump', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(home: HomeManager(GlobalKey())));
    });

  });
}

