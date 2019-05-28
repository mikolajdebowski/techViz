
import 'dart:async';

import 'package:techviz/model/escalationPath.dart';
import 'package:techviz/repository/async/IRouting.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/local/escalationPathTable.dart';
import 'package:techviz/repository/remoteRepository.dart';

class EscalationPathRepository implements IRepository<EscalationPath> {
  IRemoteRepository remoteRepository;
  IRouting<EscalationPath> remoteRouting;

  EscalationPathRepository({this.remoteRepository});

  @override
  Future fetch() {
    assert(remoteRepository != null);
    return remoteRepository.fetch();
  }

  Future<List<EscalationPath>> getAll() async {
    return EscalationPathTable().getAll();
  }
}