import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:techviz/components/dataEntry/dataEntryGroup.dart';
import 'package:techviz/model/role.dart';
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
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:techviz/session.dart';
import '../repository/mock/localRepositoryMock.dart';
import '../repository/mock/slotFloorRemoteRepositoryMock.dart';
import '../repository/processor/mock/TaskRemoteRepositoryMock.dart';

class ManagerViewPresenterViewImpl extends Mock implements IManagerViewPresenter{}

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

    List<Map<String,dynamic>> listToReturn = <Map<String,dynamic>>[];

    //TEST CASES:
    // Off Shift (UserStatusID = 10)
    // IN TOTAL: 10 ENTRIES
    // <10 ON STATUS 10

    //Available (UserStatusID IN 20,30,35)
    // IN TOTAL: 30 ENTRIES
    // <20 ON STATUS 20
    // <30 ON STATUS 30
    // <40 ON STATUS 35

    //On Break (UserStatusID IN 45,50,55)
    // IN TOTAL: 30 ENTRIES
    // <50 ON STATUS 45
    // <60 ON STATUS 50
    // <70 ON STATUS 55

    //Other (UserStatusID IN 70,75,80,90)
    // IN TOTAL: 40 ENTRIES
    // 70<80 ON STATUS 70
    // 80<90 ON STATUS 75
    // 100<100 ON STATUS 80
    // 110<110 ON STATUS 90

    int generateStatusID(final int i){
      if(i<10)
        return 10;

      if(i<20)
        return 20;
      else if(i<30)
        return 30;
      else if(i<40)
        return 35;

      if(i<50)
        return 45;
      else if(i<60)
        return 50;
      else if(i<70)
        return 55;

      if(i<80)
        return 70;
      else if(i<90)
        return 75;
      else if(i<100)
        return 80;
      else
        return 90;
    }

    for(int i =0; i < 110; i++){
      Map<String,dynamic> mapEntry = <String,dynamic>{};
      mapEntry['UserID'] = i.toString();
      mapEntry['UserName'] = i.toString();
      mapEntry['UserStatusID'] = generateStatusID(i).toString();
      mapEntry['UserStatusName'] = i.toString();
      mapEntry['TaskCount'] = i.toString();
      mapEntry['SectionCount'] = i.toString();
      listToReturn.add(mapEntry);
    }
    return Future<List<Map>>.value(listToReturn);
  }

  @override
  Future<List<Map>> usersBySectionsByTaskCount() {
    throw UnimplementedError();
  }
}

void main(){

  setUpAll((){
    Role role = Role(isSupervisor: true);
    Session().role = role;
    kiwi.Container().registerInstance(TaskRepository(TaskRemoteRepositoryMock(), LocalRepositoryMock()));

    Repository().taskTypeRepository = TaskTypeRepository(null, TaskTypeTableMock());
    Repository().taskStatusRepository = TaskStatusRepository(null, TaskStatusTableMock());
    Repository().userRepository = UserRepository(UserRemoteRepositoryMock(), null);
    Repository().slotFloorRepository = SlotFloorRepository(SlotFloorRemoteRepositoryMock(), null);
  });

  test('loadOpenTasks should call back onOpenTasksLoaded', () async{
    IManagerViewPresenter view = ManagerViewPresenterViewImpl();
    ManagerViewPresenter presenter = ManagerViewPresenter(view);
    presenter.loadOpenTasks();

    await untilCalled(view.onOpenTasksLoaded(any));

    VerificationResult result = verify(view.onOpenTasksLoaded(captureAny));
    expect(result.callCount, 1, reason: 'onOpenTasksLoaded not called once');
    // TODO(rmathias): check the captured value ////// (result.captured, <DataEntryGroup>[], reason: 'not a list');
  });

  test('loadSlotFloorSummary should call back onSlotFloorSummaryLoaded', () async{
    IManagerViewPresenter view = ManagerViewPresenterViewImpl();
    ManagerViewPresenter presenter = ManagerViewPresenter(view);
    presenter.loadSlotFloorSummary();

    await untilCalled(view.onSlotFloorSummaryLoaded(any));

    VerificationResult result = verify(view.onSlotFloorSummaryLoaded(captureAny));
    expect(result.callCount, 1, reason: 'onSlotFloorSummaryLoaded not called once');
  });

  test('loadTeamAvailability should call back onTeamAvailabilityLoaded', () async{
    IManagerViewPresenter view = ManagerViewPresenterViewImpl();
    ManagerViewPresenter presenter = ManagerViewPresenter(view);
    presenter.loadTeamAvailability();

    await untilCalled(view.onTeamAvailabilityLoaded(any));

    VerificationResult result = verify(view.onTeamAvailabilityLoaded(captureAny));
    expect(result.callCount, 1, reason: 'onTeamAvailabilityLoaded not called once');

    List<DataEntryGroup> listDataEntryGroup = result.captured[0] as List<DataEntryGroup>;
    DataEntryGroup availableGroup = listDataEntryGroup.where((DataEntryGroup deg) => deg.headerTitle == 'Available').first;
    DataEntryGroup onBreakGroup = listDataEntryGroup.where((DataEntryGroup deg) => deg.headerTitle == 'On Break').first;
    DataEntryGroup otherGroup = listDataEntryGroup.where((DataEntryGroup deg) => deg.headerTitle == 'Other').first;
    DataEntryGroup offShiftGroup = listDataEntryGroup.where((DataEntryGroup deg) => deg.headerTitle == 'Off Shift').first;

    expect(availableGroup.entries.length, 30);
    expect(onBreakGroup.entries.length, 30);
    expect(otherGroup.entries.length, 40);
    expect(offShiftGroup.entries.length, 10);
  });
}