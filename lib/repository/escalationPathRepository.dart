import 'dart:async';
import 'package:techviz/model/escalationPath.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/local/escalationPathTable.dart';
import 'package:techviz/repository/remoteRepository.dart';

class EscalationPathRepository implements IRepository<EscalationPath> {
  IRemoteRepository _remoteRepository;
  EscalationPathTable _escalationPathTable;

  EscalationPathRepository(this._remoteRepository, this._escalationPathTable){
    assert(_remoteRepository!=null);
    assert(_escalationPathTable!=null);
  }

  @override
  Future fetch() {
    assert(_remoteRepository != null);
    return _remoteRepository.fetch().then<int>((dynamic fetched){
      return _escalationPathTable.insert(fetched);
    });
  }

  Future<List<EscalationPath>> getAll(bool techPaths) async {
    return _escalationPathTable.getAll(techPaths);
  }
}