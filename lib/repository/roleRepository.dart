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

    String sqlQuery = "SELECT UserRoleID, UserRoleName FROM Role";
    if(ids!=null || ids.length>0){
      sqlQuery += " WHERE UserRoleID IN (${ids.join(',')})";
    }

    List<Map<String, dynamic>> queryResult = await localRepo.db.rawQuery(sqlQuery);

    List<Role> toReturn = List<Role>();
    queryResult.forEach((Map<String, dynamic> role) {
      var t = Role(
        id: role['UserRoleID'] as int,
        description: role['UserRoleName'] as String,
      );
      toReturn.add(t);
    });

    return toReturn;
  }

  @override
  Future listen(Function callback, Function callbackError) {
    throw UnimplementedError();
  }


  @override
  Future fetch() {
    assert(this.remoteRepository!=null);
    return this.remoteRepository.fetch();
  }
}