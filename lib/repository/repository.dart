

import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/mock/mockTaskRepository.dart';
import 'package:techviz/repository/rest/restTaskRepository.dart';

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

  IRepository get taskRepository {
    switch(_flavor) {
      case Flavor.MOCK: return MockTaskRepository();
      default: return RestTaskRepository();
    }
  }
}