import 'dart:async';
import 'package:techviz/model/userRole.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/localRepository.dart';

abstract class IUserRoleRepository implements IRepository<dynamic>{
  Future<List<UserRole>> getUserRoles(String userID);
}

class UserRoleRepository implements IUserRoleRepository{

  /**
   * fetch local
   */
  @override
  Future<List<UserRole>> getUserRoles(String userID) async {
    LocalRepository localRepo = LocalRepository();

    String sql = "SELECT UserID, UserRoleID, UserRoleName FROM UserRole";
    List<Map<String, dynamic>> queryResult = await localRepo.rawQuery(sql);

    List<UserRole> toReturn = List<UserRole>();
    queryResult.forEach((Map<String, dynamic> role) {
      var t = UserRole(
        userID: role['UserID'] as String,
        roleID: role['UserRoleID'] as int,
        roleDescription: role['UserRoleName'] as String,
      );
      toReturn.add(t);
    });

    return toReturn;
  }

  /**
   * fetch remote
   */
  @override
  Future<List> fetch() {
    throw new UnimplementedError('Needs to be overwritten');
  }
}