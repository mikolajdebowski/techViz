import 'dart:async';

import 'package:techviz/model/section.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/remoteRepository.dart';

class SectionRepository implements IRepository<Section> {
  IRemoteRepository remoteRepository;

  SectionRepository({this.remoteRepository});

  Future<List<Section>> getAll() async {
    LocalRepository localRepo = LocalRepository();

    String sqlQuery = "SELECT SectionID FROM Section";
    List<Map<String, dynamic>> queryResult = await localRepo.db.rawQuery(sqlQuery);

    List<Section> toReturn = List<Section>();
    queryResult.forEach((Map<String, dynamic> role) {
      var t = Section(role['SectionID'] as String);
      toReturn.add(t);
    });

    return toReturn;
  }

  @override
  Future fetch() {
    assert(this.remoteRepository != null);
    return this.remoteRepository.fetch();
  }
}
