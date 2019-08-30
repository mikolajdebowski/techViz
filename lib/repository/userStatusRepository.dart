import 'dart:async';
import 'package:techviz/model/userStatus.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/remoteRepository.dart';

abstract class IUserStatusRepository{
  Future<List<UserStatus>> getStatuses();
  Future fetch();
}

class UserStatusRepository implements IUserStatusRepository {
  IRemoteRepository remoteRepository;
  ILocalRepository localRepository;
  UserStatusRepository(this.remoteRepository, this.localRepository);

  @override
  Future<List<UserStatus>> getStatuses() async {
    LocalRepository localRepo = LocalRepository();

    String sql = "SELECT UserStatusID, Description, IsOnline FROM UserStatus";
    List<Map<String, dynamic>> queryResult = await localRepo.db.rawQuery(sql);

    List<UserStatus> toReturn = <UserStatus>[];
    queryResult.forEach((Map<String, dynamic> status) {
      UserStatus t = UserStatus(
        status['UserStatusID'] as int,
        status['Description'] as String,
        (status['IsOnline'] as int) == 1 ? true : false,
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