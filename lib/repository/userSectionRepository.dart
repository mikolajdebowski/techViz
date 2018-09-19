import 'dart:async';
import 'package:techviz/model/userRole.dart';
import 'package:techviz/model/userSection.dart';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/local/localRepository.dart';
import 'package:techviz/repository/rabbitmq/channel/userSectionChannel.dart';
import 'package:techviz/repository/remoteRepository.dart';

typedef UserSectionUpdateCallBack = void Function(String userID);

class UserSectionRepository implements IRepository<UserSection>{
  IRemoteRepository remoteRepository;
  UserSectionRepository({this.remoteRepository});

  Future<List<UserSection>> getUserSection(String userID) async {
    LocalRepository localRepo = LocalRepository();

    String sql = "SELECT UserID, SectionID FROM UserSection";
    List<Map<String, dynamic>> queryResult = await localRepo.rawQuery(sql);

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

  Future update(String userID, List<String> sections, {UserSectionUpdateCallBack callBack, bool updateRemote = true} ) async {
    print('updating local...');
    LocalRepository localRepo = LocalRepository();
    await localRepo.open();

    if(sections!=null){
//      sections.forEach((String s) {
//        localRepo.db.rawUpdate('UPDATE UserSection SET SectionID = ? WHERE UserID = ?', [s, userID].toList());
//      });tv

      await localRepo.db.rawUpdate('UPDATE UserSection SET SectionID = ? WHERE UserID = ?', [sections, userID].toList());
    }
    await localRepo.db.close();

    if(updateRemote){
      var toSend = {'userID': userID, 'sections': sections};
      UserSectionChannel userSectionChannel = UserSectionChannel();
      await userSectionChannel.submit(toSend);

      print('rabbitmq update sent');
    }
//
//    if(callBack!=null){
//      callBack(userID);
//    }
  }

  @override
  Future fetch() {
    assert(this.remoteRepository!=null);
    return this.remoteRepository.fetch();
  }

  @override
  Future listen() {
    throw UnimplementedError();
  }

}