

import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/iTaskRepository.dart';
import 'package:techviz/repository/mock/mockTaskRepository.dart';
import 'package:techviz/repository/rest/restTaskRepository.dart';
import 'package:techviz/repository/rest/restTaskStatusRepository.dart';
import 'package:techviz/repository/rest/restTaskTypeRepository.dart';

enum Flavor {
  MOCK,
  REST
}

class Repository{
  static final Repository _singleton = new Repository._internal();
  static Flavor _flavor;

  static void configure(Flavor flavor) {
    _flavor = flavor;
  }

  factory Repository() {
    return _singleton;
  }

  Repository._internal();

  ITaskRepository get taskRepository {
    switch(_flavor) {
      case Flavor.MOCK: return MockTaskRepository();
      default: return RestTaskRepository();
    }
  }

  IRepository get taskStatusRepository {
    switch(_flavor) {
      default: return RestTaskStatusRepository();
    }
  }

  IRepository get taskTypeRepository {
    switch(_flavor) {
      default: return RestTaskTypeRepository();
    }
  }
}