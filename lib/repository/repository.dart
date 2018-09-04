import 'dart:async';

import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/localRepository.dart';
import 'package:techviz/repository/processor/processorRepositoryFactory.dart';
import 'package:techviz/repository/processor/processorRoleRepository.dart';
import 'package:techviz/repository/processor/processorUserRepository.dart';
import 'package:techviz/repository/processor/processorUserRoleRepository.dart';
import 'package:techviz/repository/roleRepository.dart';
import 'package:techviz/repository/userRepository.dart';
import 'package:techviz/repository/userRoleRepository.dart';
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

  Future<void> fetch(fncOnMessage onMessage) async{


    onMessage('Fetching User Data...');
    await userRepository.fetch();

    onMessage('Fetching Roles...');
    await rolesRepository.fetch();
    await userRolesRepository.fetch();
//
//    onMessage('Fetching User Statuses...');
//    await userStatusRepository.fetch();
//
//    onMessage('Fetching Tasks...');
//    await taskRepository.fetch();
//
//    onMessage('Fetching Task Statuses...');
//    await taskStatusRepository.fetch();
//
//    onMessage('Fetching Task Types...');
//    await taskTypeRepository.fetch();
//
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
      default: return  UserRoleRepository(remoteRepository: ProcessorUserRoleRepository());
    }
  }

//
//
//
//  ITaskRepository get taskRepository {
//    switch(_flavor) {
////      case Flavor.PROCESSOR: return ProcessorTaskRepository();
////      default:return MockTaskRepository();
//      default:return ProcessorTaskRepository();
//    }
//  }
//
//  IRepository get taskStatusRepository {
//    switch(_flavor) {
//      default: return ProcessorTaskStatusRepository();
//    }
//  }
//
//  IRepository get taskTypeRepository {
//    switch(_flavor) {
//      default: return ProcessorTaskTypeRepository();
//    }
//  }
//
//  IRoleRepository get rolesRepository {
//    switch(_flavor) {
//      default: return ProcessorRoleRepository();
//    }
//  }
//

//
//
//
//  IUserStatusRepository get userStatusRepository {
//    switch(_flavor) {
//      default: return ProcessorUserStatusRepository();
//    }
//  }
}