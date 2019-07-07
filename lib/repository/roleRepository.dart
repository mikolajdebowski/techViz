import 'dart:async';
import 'package:techviz/model/role.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/remoteRepository.dart';

class RoleRepository {
  IRemoteRepository remoteRepository;
  ILocalRepository localRepository;
  RoleRepository(this.remoteRepository, this.localRepository);

  Future<List<Role>> getAll({List<String> ids}) async {
    String sqlQuery = "SELECT * FROM Role";
    if(ids!=null || ids.isNotEmpty){
      sqlQuery += " WHERE UserRoleID IN (${ids.join(',')})";
    }

    List<Map<String, dynamic>> queryResult = await localRepository.db.rawQuery(sqlQuery);

    List<Role> toReturn = <Role>[];
    queryResult.forEach((Map<String, dynamic> role) {
      var t = Role(
        id: role['UserRoleID'] as int,
        description: role['UserRoleName'] as String,
        isAttendant: role['IsAttendant'] == 1,
        isManager: role['IsManager'] == 1,
        isSupervisor: role['IsSupervisor']  == 1,
        isTechManager: role['IsTechManager'] == 1,
        isTechnician: role['IsTechnician'] == 1,
        isTechSupervisor: role['IsTechSupervisor'] == 1,
      );
      toReturn.add(t);
    });

    return toReturn;
  }

  Future fetch() {
    assert(remoteRepository!=null);
    return remoteRepository.fetch();
  }
}