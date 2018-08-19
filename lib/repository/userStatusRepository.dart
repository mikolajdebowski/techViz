import 'dart:async';
import 'package:techviz/model/userRole.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/localRepository.dart';

abstract class IUserStatusRepository implements IRepository<dynamic>{
  Future<List<UserStatus>> getStatuses();
}

class UserStatusRepository implements IUserStatusRepository{

  /**
   * fetch local
   */
  @override
  Future<List<UserStatus>> getStatuses() async {
    LocalRepository localRepo = LocalRepository();

    String sql = "SELECT UserStatusID, Description FROM UserStatus";
    List<Map<String, dynamic>> queryResult = await localRepo.rawQuery(sql);

    List<UserStatus> toReturn = List<UserStatus>();
    queryResult.forEach((Map<String, dynamic> role) {
      var t = UserStatus(
        id: role['UserStatusID'] as String,
        description: role['Description'] as String
      );
      toReturn.add(t);
    });

    return toReturn;
  }

  /**
   * fetch remote
   */
  @override
  Future fetch() {
    throw new UnimplementedError('Needs to be overwritten');
  }
}