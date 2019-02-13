import 'dart:async';

import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/processor/ProcessorUserGeneralInfoRepository.dart';
import 'package:techviz/repository/processor/processorRepositoryFactory.dart';
import 'package:techviz/repository/processor/processorRoleRepository.dart';
import 'package:techviz/repository/processor/processorSectionRepository.dart';
import 'package:techviz/repository/processor/processorTaskRepository.dart';
import 'package:techviz/repository/processor/processorTaskStatusRepository.dart';
import 'package:techviz/repository/processor/processorTaskTypeRepository.dart';
import 'package:techviz/repository/processor/processorUserRepository.dart';
import 'package:techviz/repository/processor/processorUserRoleRepository.dart';
import 'package:techviz/repository/processor/processorUserSectionRepository.dart';
import 'package:techviz/repository/processor/processorUserStatusRepository.dart';
import 'package:techviz/repository/roleRepository.dart';
import 'package:techviz/repository/sectionRepository.dart';
import 'package:techviz/repository/taskRepository.dart';
import 'package:techviz/repository/taskStatusRepository.dart';
import 'package:techviz/repository/taskTypeRepository.dart';
import 'package:techviz/repository/userGeneralInfoRepository.dart';
import 'package:techviz/repository/userRepository.dart';
import 'package:techviz/repository/userRoleRepository.dart';
import 'package:techviz/repository/userSectionRepository.dart';
import 'package:techviz/repository/userStatusRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

enum Flavor {
  MOCK,
  PROCESSOR,
  IHUB
}

typedef fncOnMessage = void Function(String);

class Repository{
  static Flavor _flavor;

  static final Repository _singleton = new Repository._internal();
  factory Repository() {
    return _singleton;
  }
  Repository._internal();


  Future<void> configure(Flavor flavor, {String configJSON}) async {
    _flavor = flavor;

    if(_flavor == Flavor.PROCESSOR){
      SessionClient client = SessionClient.getInstance();
      var config = ProcessorRepositoryConfig();
      await config.Setup(client);
    }
  }

  Future<void> preFetch(fncOnMessage onMessage) async{
    onMessage('Cleaning up local database...');


    LocalRepository localRepo = LocalRepository();
    await localRepo.open();
    await localRepo.dropDatabase();
  }

  Future<void> initialFetch(fncOnMessage onMessage) async{


    //LocalRepository localRepo = LocalRepository();
//    await localRepo.open();

    onMessage('Fetching User Data...');
    await userRepository.fetch();

    onMessage('Fetching Roles...');
    await rolesRepository.fetch();
    await userRolesRepository.fetch();

    onMessage('Fetching User Status...');
    await userStatusRepository.fetch();

    onMessage('Fetching Task Status...');
    await taskStatusRepository.fetch();

    onMessage('Fetching User General Info...');
    await userGeneralInfoRepository.fetch();

    onMessage('Fetching Task Types...');
    await taskTypeRepository.fetch();

    onMessage('Fetching Sections...');
    await sectionRepository.fetch();
    await userSectionRepository.fetch();


  }

  UserSectionRepository get userSectionRepository {
    switch(_flavor) {
      default: return UserSectionRepository(remoteRepository: ProcessorUserSectionRepository());
    }
  }

  SectionRepository get sectionRepository {
    switch(_flavor) {
      default: return SectionRepository(remoteRepository: ProcessorSectionRepository());
    }
  }

  UserRepository get userRepository {
    switch(_flavor) {
      default: return UserRepository(remoteRepository: ProcessorUserRepository());
    }
  }

  RoleRepository get rolesRepository {
    switch(_flavor) {
      default: return RoleRepository(remoteRepository: ProcessorRoleRepository());
    }
  }

  UserRoleRepository get userRolesRepository {
    switch(_flavor) {
      default: return UserRoleRepository(remoteRepository: ProcessorUserRoleRepository());
    }
  }

  UserStatusRepository get userStatusRepository {
    switch(_flavor) {
      default: return UserStatusRepository(remoteRepository: ProcessorUserStatusRepository());
    }
  }

  UserGeneralInfoRepository get userGeneralInfoRepository {
    switch(_flavor) {
      default: return UserGeneralInfoRepository(remoteRepository: ProcessorUserGeneralInfoRepository());
    }
  }

  TaskTypeRepository get taskTypeRepository {
    switch(_flavor) {
      default: return TaskTypeRepository(remoteRepository: ProcessorTaskTypeRepository());
    }
  }

  TaskStatusRepository get taskStatusRepository {
    switch(_flavor) {
      default: return TaskStatusRepository(remoteRepository: ProcessorTaskStatusRepository());
    }
  }

  TaskRepository get taskRepository {
    switch(_flavor) {
//      case Flavor.PROCESSOR: return ProcessorTaskRepository();
//      default:return MockTaskRepository();
      default:return TaskRepository(remoteRepository: ProcessorTaskRepository());
    }
  }


}