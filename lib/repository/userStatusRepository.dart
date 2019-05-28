import 'dart:async';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/remoteRepository.dart';

class UserStatusRepository implements IRepository<UserStatus> {
  IRemoteRepository remoteRepository;

  UserStatusRepository({this.remoteRepository});

  Future<List<UserStatus>> getStatuses() async {
    LocalRepository localRepo = LocalRepository();

    String sql = "SELECT UserStatusID, Description, IsOnline FROM UserStatus";
    List<Map<String, dynamic>> queryResult = await localRepo.db.rawQuery(sql);

    List<UserStatus> toReturn = <UserStatus>[];
    queryResult.forEach((Map<String, dynamic> status) {
      var t = UserStatus(
        id: status['UserStatusID'] as String,
        description: status['Description'] as String,
        isOnline: (status['IsOnline'] as int) == 1 ? true : false,
      );
      toReturn.add(t);
    });

    return toReturn;
  }

  @override
  Future fetch() {
    assert(remoteRepository != null);
    return remoteRepository.fetch();
  }
}