import 'dart:async';
import 'package:techviz/model/user.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/localRepository.dart';

abstract class IUserRepository implements IRepository<dynamic>{
  Future<User> getUser();
}

class UserRepository implements IUserRepository{

  /**
   * fetch local
   */
  @override
  Future<User> getUser() async {
    LocalRepository localRepo = LocalRepository();

    String sql = "SELECT UserID, UserRoleID, UserRoleName FROM UserRole";
    List<Map<String, dynamic>> queryResult = await localRepo.rawQuery(sql);

    if(queryResult.length>0){
      Map<String, dynamic> userMap = queryResult.first;
      var u = User(
        UserID: userMap['UserID'] as String,
        SectionList: userMap['UserID'] as String

      );
      return u;
    }

    throw Exception('User was not found');
  }


  /**
   * fetch remote
   */
  @override
  Future fetch() {
    throw new UnimplementedError('Needs to be overwritten');
  }



}