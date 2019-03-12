
import 'dart:async';

import 'package:techviz/model/escalationPath.dart';
import 'package:techviz/repository/async/IRouting.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/remoteRepository.dart';

class EscalationPathRepository implements IRepository<EscalationPath> {
  IRemoteRepository remoteRepository;
  IRouting<EscalationPath> remoteRouting;

  EscalationPathRepository({this.remoteRepository});

  @override
  Future fetch() {
    assert(this.remoteRepository != null);
    return this.remoteRepository.fetch();
  }
}