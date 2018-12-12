import 'dart:async';
import 'package:techviz/model/userSection.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/rabbitmq/channel/userSectionChannel.dart';
import 'package:techviz/repository/remoteRepository.dart';

typedef UserSectionUpdateCallBack = void Function(List<String> sections);

class UserSectionRepository implements IRepository<UserSection> {
  IRemoteRepository remoteRepository;

  UserSectionRepository({this.remoteRepository});

  Future<List<UserSection>> getUserSection(String userID) async {
    LocalRepository localRepo = LocalRepository();

    String sql = "SELECT UserID, SectionID FROM UserSection WHERE UserID = '$userID'";
    List<Map<String, dynamic>> queryResult = await localRepo.db.rawQuery(sql);

    List<UserSection> toReturn = List<UserSection>();
    queryResult.forEach((Map<String, dynamic> section) {
      var s = UserSection(
        section['SectionID'] as String,
        section['UserID'] as String,
      );
      toReturn.add(s);
    });

    return toReturn;
  }

  Future update(String userID, List<String> sections,
      {UserSectionUpdateCallBack callBack, bool updateRemote = true}) async {
    print('updating local...');
    LocalRepository localRepo = LocalRepository();
    await localRepo.open();

    await localRepo.db.delete('UserSection');

    if (sections != null) {
      await sections.forEach((dynamic section) {
        Map<String, dynamic> map = Map<String, dynamic>();
        map['SectionID'] = section;
        map['UserID'] = userID;
        localRepo.insert('UserSection', map);
      });
    }

    if (updateRemote) {

      var toSend = {'userID': userID, 'sections': sections};
      UserSectionChannel userSectionChannel = UserSectionChannel();
      userSectionChannel.publishMessage(toSend);

      print('rabbitmq update sent');
    }

    if (callBack != null) {
      callBack(sections);
    }
  }

  @override
  Future fetch() {
    assert(this.remoteRepository != null);
    return this.remoteRepository.fetch();
  }

  @override
  Future listen() {
    throw UnimplementedError();
  }
}
