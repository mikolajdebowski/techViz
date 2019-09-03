import 'dart:async';
import 'package:techviz/common/http/client/sessionClient.dart';
import 'package:techviz/repository/slotFloorRepository.dart';
import 'package:techviz/repository/async/SlotMachineRouting.dart';
import 'package:techviz/repository/escalationPathRepository.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/processor/ProcessorReservationTimeRepository.dart';
import 'package:techviz/repository/processor/processorEscalationPathRepository.dart';
import 'package:techviz/repository/processor/processorRepositoryConfig.dart';
import 'package:techviz/repository/processor/processorRoleRepository.dart';
import 'package:techviz/repository/processor/processorSectionRepository.dart';
import 'package:techviz/repository/processor/processorStatsMonthRepository.dart';
import 'package:techviz/repository/processor/processorStatsTodayRepository.dart';
import 'package:techviz/repository/processor/processorStatsWeekRepository.dart';
import 'package:techviz/repository/processor/processorSlotFloorRepository.dart';
import 'package:techviz/repository/processor/processorTaskRepository.dart';
import 'package:techviz/repository/processor/processorTaskStatusRepository.dart';
import 'package:techviz/repository/processor/processorTaskTypeRepository.dart';
import 'package:techviz/repository/processor/processorTaskUrgencyRepository.dart';
import 'package:techviz/repository/processor/processorUserRepository.dart';
import 'package:techviz/repository/processor/processorUserRoleRepository.dart';
import 'package:techviz/repository/processor/processorUserSectionRepository.dart';
import 'package:techviz/repository/processor/processorUserSkillsRepository.dart';
import 'package:techviz/repository/processor/processorUserStatusRepository.dart';
import 'package:techviz/repository/reservationTimeRepository.dart';
import 'package:techviz/repository/roleRepository.dart';
import 'package:techviz/repository/sectionRepository.dart';
import 'package:techviz/repository/statsMonthRepository.dart';
import 'package:techviz/repository/statsTodayRepository.dart';
import 'package:techviz/repository/statsWeekRepository.dart';
import 'package:techviz/repository/taskRepository.dart';
import 'package:techviz/repository/taskStatusRepository.dart';
import 'package:techviz/repository/taskTypeRepository.dart';
import 'package:techviz/repository/taskUrgencyRepository.dart';
import 'package:techviz/repository/userRepository.dart';
import 'package:techviz/repository/userRoleRepository.dart';
import 'package:techviz/repository/userSectionRepository.dart';
import 'package:techviz/repository/userSkillsRepository.dart';
import 'package:techviz/repository/userStatusRepository.dart';
import 'package:techviz/repository/workOrder.repository.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

import 'async/MessageClient.dart';
import 'local/escalationPathTable.dart';
import 'local/taskStatusTable.dart';
import 'local/taskTypeTable.dart';
import 'local/userSectionTable.dart';
import 'local/userTable.dart';

enum Flavor {
  MOCK,
  PROCESSOR,
  IHUB
}

typedef fncOnMessage = void Function(String);

class Repository {
  UserRepository _userRepository;
  UserSectionRepository _userSectionRepository;
  ITaskTypeRepository _taskTypeRepository;
  TaskStatusRepository _taskStatusRepository;
  SlotFloorRepository _slotFloorRepository;
  EscalationPathRepository _escalationPathRepository;
  IWorkOrderRepository _workOrderRepository;

  ILocalRepository _localRepository;
  static Flavor _flavor;

  static final Repository _singleton = Repository._internal();
  factory Repository() {
    return _singleton;
  }
  Repository._internal();



  Future<void> configure(Flavor flavor, {String configJSON}) async {
    _flavor = flavor;

    _localRepository ??= LocalRepository();

    if(_flavor == Flavor.PROCESSOR){
      SessionClient client = SessionClient();
      var config = ProcessorRepositoryConfig();
      await config.Setup(client);
    }

		_configureInjector();
  }

  void setLocalDatabase(ILocalRepository localRepository){
    _localRepository = localRepository;
  }

  Future<void> preFetch(fncOnMessage onMessage) async {
    onMessage('Cleaning up local database...');


    LocalRepository localRepo = LocalRepository();
    await localRepo.open();
    await localRepo.dropDatabase();
  }

  Future<void> initialFetch(fncOnMessage onMessage) async {

    LocalRepository localRepo = LocalRepository();
    await localRepo.open();

    onMessage('Fetching User Info...');
    await userRepository.fetch();

    onMessage('Fetching Roles...');
    await roleRepository.fetch();
    await userRolesRepository.fetch();

    onMessage('Fetching User Status...');
    await userStatusRepository.fetch();

    onMessage('Fetching Task Status...');
    await taskStatusRepository.fetch();

    onMessage('Fetching Task Types...');
    await taskTypeRepository.fetch();

    onMessage('Fetching Task Urgency...');
    await taskUrgencyRepository.fetch();

    onMessage('Fetching Escalation Path...');
    await escalationPathRepository.fetch();

    onMessage('Fetching Sections...');
    await sectionRepository.fetch();
    await userSectionRepository.fetch();
  }

  void _configureInjector(){
    kiwi.Container container = kiwi.Container();
    container.clear();
    container.registerInstance(TaskRepository(ProcessorTaskRepository(ProcessorRepositoryConfig()), _localRepository));
    container.registerInstance(UserRoleRepository(ProcessorUserRoleRepository(), _localRepository));
    container.registerInstance(RoleRepository(ProcessorRoleRepository(), _localRepository));
    container.registerInstance<IUserStatusRepository, UserStatusRepository>(UserStatusRepository(ProcessorUserStatusRepository(), _localRepository));

  }

  //TASKS
  TaskRepository get taskRepository => kiwi.Container().resolve<TaskRepository>();
  UserRoleRepository get userRolesRepository => kiwi.Container().resolve<UserRoleRepository>();
  RoleRepository get roleRepository => kiwi.Container().resolve<RoleRepository>();
  IUserStatusRepository get userStatusRepository => kiwi.Container().resolve<IUserStatusRepository>();

  //USERS
  UserRepository get userRepository {
    IUserTable userTableImpl = UserTable(_localRepository);
    if(_userRepository==null){
      return UserRepository(ProcessorUserRepository(ProcessorRepositoryConfig()), userTableImpl);
    }
    assert(_userRepository!=null);
    return _userRepository;
  }
  set userRepository(UserRepository userRepository){
    _userRepository = userRepository;
  }

  //USERSECTIONS
  UserSectionRepository get userSectionRepository {
    IUserSectionTable userSectionTable = UserSectionTable(_localRepository);
    if(_userSectionRepository!=null){
      return _userSectionRepository;
    }
    return _userSectionRepository = UserSectionRepository(ProcessorUserSectionRepository(), userSectionTable);
  }
  set userSectionRepository(UserSectionRepository userSectionRepository){
    _userSectionRepository = userSectionRepository;
  }

  ITaskTypeRepository get taskTypeRepository {
    if(_taskTypeRepository!=null){
      return _taskTypeRepository;
    }
    return _taskTypeRepository = TaskTypeRepository(ProcessorTaskTypeRepository(ProcessorRepositoryConfig()), TaskTypeTable(_localRepository));
  }
  set taskTypeRepository(ITaskTypeRepository taskTypeRepository){
    _taskTypeRepository = taskTypeRepository;
  }


  TaskStatusRepository get taskStatusRepository {
    if(_taskStatusRepository!=null){
      return _taskStatusRepository;
    }
    return _taskStatusRepository = TaskStatusRepository(ProcessorTaskStatusRepository(ProcessorRepositoryConfig()), TaskStatusTable(_localRepository));
  }
  set taskStatusRepository(TaskStatusRepository taskStatusRepository){
    _taskStatusRepository = taskStatusRepository;
  }


  SlotFloorRepository get slotFloorRepository {
    if(_slotFloorRepository!=null){
      return _slotFloorRepository;
    }
    return _slotFloorRepository = SlotFloorRepository(ProcessorSlotFloorRepository(ProcessorRepositoryConfig()), SlotMachineRouting(MessageClient()));
  }
  set slotFloorRepository(SlotFloorRepository slotFloorRepository){
    _slotFloorRepository = slotFloorRepository;
  }

  EscalationPathRepository get escalationPathRepository {
    if(_escalationPathRepository!=null){
      return _escalationPathRepository;
    }
    return _escalationPathRepository = EscalationPathRepository(ProcessorEscalationPathRepository(), EscalationPathTable(_localRepository));
  }
  set escalationPathRepository(EscalationPathRepository escalationPathRepository){
    _escalationPathRepository = escalationPathRepository;
  }


  IWorkOrderRepository get workOrderRepository {
    if(_workOrderRepository!=null){
      return _workOrderRepository;
    }
    return _workOrderRepository = WorkOrderRepository(MessageClient());
  }
  set workOrderRepository(IWorkOrderRepository workOrderRepository){
    _workOrderRepository = workOrderRepository;
  }



  // TODO(rmathias): BELLOW MUST BE REVISED
  SectionRepository get sectionRepository {
    switch(_flavor) {
      default: return SectionRepository(remoteRepository: ProcessorSectionRepository());
    }
  }

  TaskUrgencyRepository get taskUrgencyRepository {
    switch(_flavor) {
      default: return TaskUrgencyRepository(remoteRepository: ProcessorTaskUrgencyRepository());
    }
  }

  ReservationTimeRepository get reservationTimeRepository {
    switch(_flavor) {
      default:return ReservationTimeRepository(remoteRepository: ProcessorReservationTimeRepository());
    }
  }

  StatsTodayRepository get statsTodayRepository {
    switch(_flavor) {
      default:return StatsTodayRepository(remoteRepository: ProcessorStatsTodayRepository());
    }
  }

  StatsWeekRepository get statsWeekRepository {
    switch(_flavor) {
      default:return StatsWeekRepository(remoteRepository: ProcessorStatsWeekRepository());
    }
  }

  StatsMonthRepository get statsMonthRepository {
    switch(_flavor) {
      default:return StatsMonthRepository(remoteRepository: ProcessoStatsMonthRepository());
    }
  }



  UserSkillsRepository get userSkillsRepository {
    return UserSkillsRepository(remoteRepository: ProcessorUserSkillsRepository());
  }
}