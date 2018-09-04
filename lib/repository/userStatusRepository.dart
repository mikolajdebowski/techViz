import 'dart:async';
import 'package:techviz/model/userRole.dart';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/localRepository.dart';

//abstract class IUserStatusRepository implements IRepository<dynamic>{
//  Future<List<UserStatus>> getStatuses();
//}
//
//class UserStatusRepository implements IUserStatusRepository{
//
//  /**
//   * fetch local
//   */
//  @override
//  Future<List<UserStatus>> getStatuses() async {
//    LocalRepository localRepo = LocalRepository();
//
//    String sql = "SELECT UserStatusID, Description, IsOnline FROM UserStatus";
//    List<Map<String, dynamic>> queryResult = await localRepo.rawQuery(sql);
//
//    List<UserStatus> toReturn = List<UserStatus>();
//    queryResult.forEach((Map<String, dynamic> status) {
//      var t = UserStatus(
//        id: status['UserStatusID'] as String,
//        description: status['Description'] as String,
//        isOnline: (status['IsOnline'] as int) == 1? true: false,
//      );
//      toReturn.add(t);
//    });
//
//    return toReturn;
//  }
//
//  /**
//   * fetch remote
//   */
//  @override
//  Future fetch() {
//    throw new UnimplementedError('Needs to be overwritten');
//  }
//}