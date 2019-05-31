
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:techviz/model/role.dart';
import 'package:techviz/model/user.dart';
import 'package:techviz/model/userSection.dart';
import 'package:techviz/repository/local/userSectionTable.dart';
import 'package:techviz/repository/local/userTable.dart';
import 'package:techviz/repository/repository.dart';
import 'package:techviz/repository/userRepository.dart';
import 'package:techviz/repository/userSectionRepository.dart';
import 'package:techviz/session.dart';
import 'package:techviz/ui/home.dart';
import '../repository/userRepository_test.dart';

class SessionHelper {

  Session get attendantSession {
    Session session = Session();
    session.user = User(userID: '10');
    session.role = Role(isAttendant: true);
    return session;
  }
}

class UserTableMock implements IUserTable{
  @override
  Future<User> getUser(String userID) {
    if(userID == '1'){
      return Future<User>.value(User());
    }
    else
      return null;
  }

  @override
  Future<int> update(String userID, {String statusID, String roleID}) {
    return Future<int>.value(1);
  }
}

class UserSectionRepositoryMock implements IUserSectionRemoteRepository {
  @override
  Future fetch() {
    return null;
  }
}

class UserSectionTableMock implements IUserSectionTable{
  @override
  Future<List<UserSection>> getUserSection(String userID) {
    return Future.value([]);
  }

  @override
  Future update(String userID, List<String> sections) {
    return Future<int>.value(1);
  }
}

void main() {
  testWidgets('Home widget instance test', (WidgetTester tester) async {
    Repository repository = Repository();

    UserRepository userRepo = UserRepository(UserRemoteRepositoryMock(), UserRoutingMock(), UserTableMock());
    repository.userRepository = userRepo;

    UserSectionRepository userSectionSections = UserSectionRepository(UserSectionRepositoryMock(), UserSectionTableMock());
    repository.userSectionRepository = userSectionSections;

    SessionHelper().attendantSession;

    await tester.pumpWidget(MaterialApp(home: Home()));
  });
}


