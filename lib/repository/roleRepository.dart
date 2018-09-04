import 'dart:async';
import 'package:techviz/model/role.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/localRepository.dart';
import 'package:techviz/repository/remoteRepository.dart';

class RoleRepository implements IRepository<Role>{
  IRemoteRepository remoteRepository;
  RoleRepository({this.remoteRepository});

  Future<List<Role>> getAll() async {
    LocalRepository localRepo = LocalRepository();

    List<Map<String, dynamic>> queryResult = await localRepo.rawQuery("SELECT UserRoleID, UserRoleName FROM Role");

    List<Role> toReturn = List<Role>();
    queryResult.forEach((Map<String, dynamic> role) {
      var t = Role(
        id: role['UserRoleID'] as int,
        description: role['UserRoleID'] as String,
      );
      toReturn.add(t);
    });

    return toReturn;
  }

  @override
  Future listen() {
    // TODO: implement listen
  }

  @override
  Future submit(Role object) {
    // TODO: implement submit
  }

  @override
  Future fetch() {
    assert(this.remoteRepository!=null);
    return this.remoteRepository.fetch();
  }
}