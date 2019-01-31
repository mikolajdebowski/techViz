import 'dart:async';
import 'package:techviz/model/userSection.dart';
//import 'package:techviz/repository/async/messageClient.dart.old';
import 'package:techviz/repository/common/IRepository.dart';
import 'package:techviz/repository/local/localRepository.dart';
//import 'package:techviz/repository/async/userSectionMessage.dart';
import 'package:techviz/repository/remoteRepository.dart';
import 'package:vizexplorer_mobile_common/vizexplorer_mobile_common.dart';

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

  void update(String userID, List<String> sections) async{

    LocalRepository localRepo = LocalRepository();
    await localRepo.open();
    await localRepo.db.delete('UserSection');

    if (sections != null) {
      Future.forEach(sections, (dynamic section) async{
        Map<String, dynamic> map = Map<String, dynamic>();
        map['SectionID'] = section;
        map['UserID'] = userID;
        await localRepo.insert('UserSection', map);
      });
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
