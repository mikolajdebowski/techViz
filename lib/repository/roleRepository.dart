import 'dart:async';
import 'package:techviz/model/role.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/remoteRepository.dart';

class RoleRepository implements IRepository<Role>{
  IRemoteRepository remoteRepository;
  RoleRepository({this.remoteRepository});

  Future<List<Role>> getAll({List<String> ids}) async {
    LocalRepository localRepo = LocalRepository();

    String sqlQuery = "SELECT * FROM Role";
    if(ids!=null || ids.isNotEmpty){
      sqlQuery += " WHERE UserRoleID IN (${ids.join(',')})";
    }

    List<Map<String, dynamic>> queryResult = await localRepo.db.rawQuery(sqlQuery);

    List<Role> toReturn = List<Role>();
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

  @override
  Future fetch() {
    assert(this.remoteRepository!=null);
    return this.remoteRepository.fetch();
  }
}