import 'dart:async';

import 'package:techviz/model/userSection.dart';

import 'localRepository.dart';
import 'localTable.dart';

abstract class IUserSectionTable {
  Future<List<UserSection>> getUserSection(String userID);
  Future update(String userID, List<String> sections);
}

class UserSectionTable extends LocalTable implements IUserSectionTable{
  UserSectionTable(ILocalRepository localRepo): super(localRepo: localRepo){
    createSQL = '''
            create table UserSection ( 
                SectionID TEXT NOT NULL,
                UserID TEXT NOT NULL
                )
            ''';
  }

  @override
  Future<List<UserSection>> getUserSection(String userID) async {
    String sql = "SELECT UserID, SectionID FROM UserSection WHERE UserID = '$userID'";
    List<Map<String, dynamic>> queryResult = await localRepo.db.rawQuery(sql);

    List<UserSection> toReturn = <UserSection>[];
    queryResult.forEach((Map<String, dynamic> section) {
      UserSection s = UserSection(
        section['SectionID'] as String,
        section['UserID'] as String,
      );
      toReturn.add(s);
    });
    return toReturn;
  }

  @override
  Future update(String userID, List<String> sections) async {
    Completer<void> _completer = Completer<void>();
    await localRepo.db.delete('UserSection');

    if (sections != null) {
      var batch = localRepo.db.batch();

      await Future.forEach(sections, (dynamic section) async{
        Map<String, dynamic> map = <String, dynamic>{};
        map['SectionID'] = section;
        map['UserID'] = userID;
        await localRepo.db.insert('UserSection', map);
      });

      batch.commit().then((dynamic d){
        _completer.complete();
      });
    }
    return _completer.future;
  }
}