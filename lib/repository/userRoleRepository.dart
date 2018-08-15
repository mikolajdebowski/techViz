import 'dart:async';
import 'package:techviz/model/role.dart';
import 'package:techviz/model/taskType.dart';
import 'package:techviz/model/userRole.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/localRepository.dart';

abstract class IUserRoleRepository implements IRepository<dynamic>{
  Future<List<UserRole>> getAll();
}

class UserRoleRepository implements IUserRoleRepository{

  /**
   * fetch local
   */
  @override
  Future<List<UserRole>> getAll() async {
    LocalRepository localRepo = LocalRepository();

    List<Map<String, dynamic>> queryResult = await localRepo.rawQuery("SELECT UserID, UserRoleID, UserRoleName FROM UserRole");

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
  Future<List<dynamic>> fetch() {
    throw new UnimplementedError('Needs to be overwritten');
  }
}