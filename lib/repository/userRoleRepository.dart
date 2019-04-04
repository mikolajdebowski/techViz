import 'dart:async';
import 'package:techviz/model/userRole.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/remoteRepository.dart';

class UserRoleRepository implements IRepository<UserRole>{
  IRemoteRepository remoteRepository;
  UserRoleRepository({this.remoteRepository});

  Future<List<UserRole>> getUserRoles(String userID) async {
    LocalRepository localRepo = LocalRepository();

    String sql = "SELECT UserID,UserRoleID FROM UserRole WHERE UserID = '$userID';";

    List<Map<String, dynamic>> queryResult = await localRepo.db.rawQuery(sql);

    List<UserRole> toReturn = List<UserRole>();
    queryResult.forEach((Map<String, dynamic> role) {
      UserRole ur = UserRole(
        userID: role['UserID'] as String,
        roleID: role['UserRoleID'] as int,
      );
      toReturn.add(ur);
    });

    return toReturn;
  }

  @override
  Future fetch() {
    assert(this.remoteRepository!=null);
    return this.remoteRepository.fetch();
  }
}