import 'dart:async';
import 'package:techviz/model/userRole.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/remoteRepository.dart';

class UserRoleRepository {
  IRemoteRepository remoteRepository;
  ILocalRepository localRepository;
  UserRoleRepository(this.remoteRepository, this.localRepository);

  Future<List<UserRole>> getUserRoles(String userID) async {

    String sql = "SELECT UserID,UserRoleID FROM UserRole WHERE UserID = '$userID';";

    List<Map<String, dynamic>> queryResult = await localRepository.db.rawQuery(sql);

    List<UserRole> toReturn = <UserRole>[];
    queryResult.forEach((Map<String, dynamic> role) {
      UserRole ur = UserRole(
        userID: role['UserID'] as String,
        roleID: role['UserRoleID'] as int,
      );
      toReturn.add(ur);
    });

    return toReturn;
  }

  Future fetch() {
    assert(remoteRepository!=null);
    return remoteRepository.fetch();
  }
}