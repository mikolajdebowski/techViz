import 'dart:async';
import 'package:techviz/model/userSection.dart';

import 'local/userSectionTable.dart';

typedef UserSectionUpdateCallBack = void Function(List<String> sections);

abstract class IUserSectionRemoteRepository{
  Future fetch();
}

class UserSectionRepository  {
  IUserSectionTable userSectionTable;
  IUserSectionRemoteRepository remoteRepository;
  UserSectionRepository(this.remoteRepository, this.userSectionTable);

  Future<List<UserSection>> getUserSections(String userID){
    return userSectionTable.getUserSections(userID);
  }

  Future update(String userID, List<String> sections){
    return userSectionTable.update(userID, sections);
  }

  Future fetch() {
    assert(remoteRepository != null);
    return remoteRepository.fetch();
  }
}
