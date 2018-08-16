import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/processor/processorRepositoryFactory.dart';
import 'package:techviz/repository/processor/processorRoleRepository.dart';
import 'package:techviz/repository/processor/processorUserRepository.dart';
import 'package:techviz/repository/processor/processorUserRoleRepository.dart';
import 'package:techviz/repository/roleRepository.dart';
import 'package:techviz/repository/taskRepository.dart';
import 'package:techviz/repository/mock/mockTaskRepository.dart';
import 'package:techviz/repository/processor/processorTaskRepository.dart';
import 'package:techviz/repository/processor/processorTaskStatusRepository.dart';
import 'package:techviz/repository/processor/processorTaskTypeRepository.dart';
import 'package:techviz/repository/userRepository.dart';
import 'package:techviz/repository/userRoleRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

enum Flavor {
  MOCK,
  PROCESSOR,
  IHUB
}

class Repository{
  static Flavor _flavor;

  static final Repository _singleton = new Repository._internal();
  factory Repository() {
    return _singleton;
  }
  Repository._internal();


  void configure(Flavor flavor, {String configJSON}) async {
    _flavor = flavor;

    if(_flavor == Flavor.PROCESSOR){
      SessionClient client = SessionClient.getInstance();
      var config = ProcessorRepositoryConfig();
      await config.Setup(client);
    }
  }

  ITaskRepository get taskRepository {
    switch(_flavor) {
      case Flavor.PROCESSOR: return ProcessorTaskRepository();
      default:return MockTaskRepository();
    }
  }

  IRepository get taskStatusRepository {
    switch(_flavor) {
      default: return ProcessorTaskStatusRepository();
    }
  }

  IRepository get taskTypeRepository {
    switch(_flavor) {
      default: return ProcessorTaskTypeRepository();
    }
  }

  IRoleRepository get rolesRepository {
    switch(_flavor) {
      default: return ProcessorRoleRepository();
    }
  }

  IUserRoleRepository get userRolesRepository {
    switch(_flavor) {
      default: return ProcessorUserRoleRepository();
    }
  }

  IUserRepository get userRepository {
    switch(_flavor) {
      default: return ProcessorUserRepository();
    }
  }
}